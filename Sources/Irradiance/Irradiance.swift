// Calculates panel irradiance spectra.
// This code, ported from NREL's spectrl2_2.c, is based on
// SERI (now NREL) technical report SERI/TR-215-2436,
// "Simple Solar Spectral Model for Direct and Diffuse Irradiance
//  on Horizontal and Tilted Planes at the Earth's Surface for
//  Cloudless Atmospheres",
// by R. Bird & C. Riordan
// As of 2018/04/11 this can be downloaded from
// https://go.nasa.gov/2NEUO4y
// ( https://www2.jpl.nasa.gov/
//         adv_tech/photovol/2016CTR/
//         SERI%20-%20Solar%20Spec%20for%20Dir%20&%20Dif%20Irrad%20on%20Planes_1984%20.pdf )

import Foundation
import SolarPos

// swiftlint:disable identifier_name

public struct Irradiance {
    public typealias Units = IrradianceResultUnits

    public static let defaultWavelengths: Spectra.Values = [0.3, 0.7, 0.8, 1.3, 2.5, 4.0]
    public static let defaultGroundRefls: Spectra.Values = [0.2, 0.2, 0.2, 0.2, 0.2, 0.2]

    public let spectra: [IrradianceRecord]
    public let reflectivity: Reflectivity

    public init(timespec: TimeSpec, location: Location,
                orientation: Orientation, atmos: AtmosphericConditions,
                wavelengths: Spectra.Values = defaultWavelengths,
                groundRefls: Spectra.Values = defaultGroundRefls,
                outputUnits units: Units = .irradiance) throws {
        // TBD input validation

        reflectivity = Reflectivity(waveOrFreq: wavelengths, ground: groundRefls)

        let irrInfo = try IrradianceConditions(
            timespec: timespec, location: location, orientation: orientation,
            temperature: atmos.temperature, pressure: atmos.pressure)

        let ozoneAbsorpt = atmos.ozoneAbsorption ?? Irradiance.calcO3(
            location: location, daynum: Double(irrInfo.daynum))

        let track = abs(orientation.tilt) > 180.0
        let ci = track ? 1.0 : irrInfo.etrTilt.cosInc
        let tilt = track ? irrInfo.refract.zenRef : orientation.tilt

        let ct = cos(rads(tilt))
        let cz = cos(rads(irrInfo.refract.zenRef))

        let ainfo = AerosolInfo(cz: cz, aaf: atmos.aerosolAssymetryFactor)
        let calculator = IrradianceCalculator(
            irrInfo: irrInfo, aerosolInfo: ainfo,
            alpha: atmos.alpha, tau500: atmos.tau500,
            ozoneAbsorpt: ozoneAbsorpt,
            waterVapor: atmos.waterVapor,
            ci: ci, ct: ct, cz: cz, // Tilt-related
            reflectivity: reflectivity,
            orientation: orientation,
            units: units)

        spectra = (0 ..< ETSpectrum.wavelength.count).map { calculator.calc($0) }
    }

    // Calculate atmospheric ozone absorption.
    /* I cannot find the reference for this calculation of atmospheric ozone.
       If this makes you nervous, please enter your own soldat->ozone value. */
    private static func calcO3(
        location: Location, daynum: Double) -> Double {
        var c1 = 150.0
        var c2 = 1.28
        var c3 = 40.0
        var c4 = -30.0
        var c5 = 3.0
        var c6 = (location.longitude > 0.0) ? 20.0 : 0.0

        if location.latitude < 0.0 {
            c1 = 100.0
            c2 = 1.5
            c3 = 30.0
            c4 = 152.625
            c5 = 2.0
            c6 = -75.0
        }

        let s1 = sin(0.9865 * rads(daynum + c4))
        let s2 = sin(c5 * rads(location.longitude + c6))
        let s3 = sin(c2 * rads(location.latitude))
        let result = 0.235 + (c1 + c3 * s1 + 20.0 * s2) * pow(s3, 2) / 1000.0
        return result
    }
}
