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
    public static let defaultWavelengths: Spectra.Values = [0.3, 0.7, 0.8, 1.3, 2.5, 4.0]
    public static let defaultGroundRefls: Spectra.Values = [0.2, 0.2, 0.2, 0.2, 0.2, 0.2]

    public let spectra: [IrradianceRecord]
    public let reflectivity: Reflectivity

    // reflectivity units desired, for each wavelength:
    public enum Units {
        case irradiance // W/m^2/micron
        case flux // photon flux (10.0e+16 /cm^2/s/micron)
        case fluxDensity // 10.0e+16/cm^2/s/eV
    }

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

        /* Equation 3-14 */
        let alg = log(1.0 - atmos.aerosolAssymetryFactor)

        /* Equation 3-12 */
        let afs = alg * (1.459 + alg * (0.1595 + alg * 0.4129))

        /* Equation 3-13 */
        let bfs = alg * (0.0783 + alg * (-0.3824 - alg * 0.5874))

        /* Equation 3-15 */
        let fsp = 1.0 - 0.5 * exp((afs + bfs / 1.8) / 1.8)

        /* Equation 3-11 */
        let fs = 1.0 - 0.5 * exp((afs + bfs * cz ) * cz)

        /* Ozone mass */
        let ozoneMass = 1.003454 / sqrt(pow(cz, 2) + 0.006908)

        let calculator = IrradianceCalculator(
            irrInfo: irrInfo, alpha: atmos.alpha, tau500: atmos.tau500,
            ozoneAbsorpt: ozoneAbsorpt, ozoneMass: ozoneMass,
            waterVapor: atmos.waterVapor,
            ci: ci, ct: ct, cz: cz, // Tilt-related
            fs: fs, fsp: fsp,
            wavelengths: wavelengths, groundRefls: groundRefls,
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

    struct IrradianceCalculator {
        fileprivate let irrInfo: IrradianceConditions
        let alpha: Double
        let tau500: Double
        let ozoneAbsorpt: Double
        let ozoneMass: Double
        let waterVapor: Double
        let ci: Double
        let ct: Double
        let cz: Double
        let fs: Double
        let fsp: Double
        let wavelengths: Spectra.Values
        let groundRefls: Spectra.Values
        let orientation: Orientation
        let units: Units

        // swiftlint:disable identifier_name
        fileprivate func calc(_ i: Int) -> IrradianceRecord {
            let airmass = irrInfo.airmass.airmass
            let ampress = irrInfo.airmass.pressure

            let wavelength = ETSpectrum.wavelength[i]
            let wvl2 = pow(wavelength, 2)
            let wvl4 = pow(wavelength, 4)

            let aw = ETSpectrum.h20Absorption[i]
            let ao = ETSpectrum.ozoneAbsorption[i]
            let au = ETSpectrum.mixedGasAbsorption[i]

            // h0: Horizontal extraterrestrial spectrum:
            let h0 = ETSpectrum.etSpectrum[i] * irrInfo.helioPos.radius

            // Equation 3-16
            let omeg = 0.945  // Single scattering albedo, 0.4 microns
            let omegp = 0.095 // Wavelength variation factor
            let omegl = omeg * exp(-omegp * pow(log(wavelength/0.4), 2))

            // Equation 2-7
            let c1 = tau500 * pow(wavelength * 2.0, -alpha)

            // Equation 2-4 - atmospheric transmittance after Rayleigh
            // (molecular) scattering:
            let tr = exp(-ampress / (wvl4 * (115.6406 - 1.3366 / wvl2)))

            // Equation 2-9 - Leckner's ozone transmittance:
            let t0 = exp(-ao * ozoneAbsorpt * ozoneMass)

            // Equation 2-8 - Leckner's water vapor transmittance
            let awwm = aw * waterVapor * airmass
            let tw = exp(-0.2385 * awwm / pow((1.0 + 20.07 * awwm), 0.45))

            // Equation 2-11 - Leckner's uniformly mixed gas transmittance
            let aum = au * ampress
            let tu = exp(-1.41 * aum / pow((1.0 + 118.3 * aum), 0.45))

            // Equation 3-9
            let tas = exp(-omegl * c1 * airmass)

            // Equation 3-10
            let taa = exp((omegl - 1.0) * c1 * airmass)

            // Equation 2-6, sort of
            let ta = exp(-c1 * airmass)

            // Formulas for prime transmittance factors may come from
            // Bird, R. E., "A Simple Spectral Model for Direct Normal and Diffuse Horizontal Irradiance,".
            // Solar Energy, Voi. 32, 1984, pp. 461-471.
            // Equation 2-4; primed airmass M = 1.8 (Section 3.1)
            let trp = exp(-1.8 / (wvl4 * (115.6406 - 1.3366 / wvl2)))

            // Equation 2-8; primed airmass M = 1.8 (Section 3.1) affect coefficients
            let aww = aw * waterVapor
            let twp = exp(-0.4293 * aww / pow((1.0 + 36.126 * aww), 0.45))

            // Equation 2-11; primed airmass M = 1.8 (Section 3.1) affects coefficients
            let tup = exp(-2.538 * au / pow((1.0 + 212.94 * au), 0.45))

            // Equation 3-9; primed airmass M = 1.8 (Section 3.1)
            let tasp = exp(-omegl * c1 * 1.8)

            // Equation 3-10; primed airmass M = 1.8 (Section 3.1)
            let taap = exp((omegl - 1.0) * c1 * 1.8)

            // Direct energy:
            let c20 = h0 * t0 * tw * tu
            let dir = c20 * tr * ta

            let c2 = c20 * cz * taa

            // Equation 3-17; c4 = Cs
            let c4 = (wavelength > 0.45) ? 1.0 : pow(wavelength + 0.55, 1.8)
            // Equation 3-8
            let rhoa = tup * twp * taap * (0.5 * (1.0 - trp) + (1.0 - fsp) * trp * (1.0 - tasp))
            // Interpolated ground reflectivity:
            let rho = linterp(x: wavelength, xvals: wavelengths, yvals: groundRefls)
            // Equation 3-5
            let dray = c2 * (1.0 - pow(tr, 0.95)) / 2.0
            // Equation 3-6
            let daer = c2 * pow(tr, 1.5) * (1.0 - tas) * fs
            // Equation 3-7
            let drgd = (dir * cz + dray + daer) * rho * rhoa / (1.0 - rho * rhoa)

            // In swift, unpacking a result tuple can lead to incorrect mappings.
            let energy = calcEnergies(
                dir: dir, cz: cz,
                dray: dray, daer: daer, drgd: drgd, c4: c4,
                rho: rho, h0: h0)
            let dtot = energy.dtot
            let dif = energy.dif

            // Adjust the values according to the units requested
            if units != .irradiance {
                let e: Double = {
                    let c = 2.9979244e14  // Used to calculate photon flux
                    let h = 6.6261762e-34 // Ditto
                    let evolt = 1.6021891e-19 // Conversions: Joules per electron-volt
                    return h * c / evolt
                }()

                let cons =  5.0340365e14  // Used to calculate photon flux
                var c1 = wavelength * cons
                var wvl = wavelength
                if units == .flux {
                    wvl = e / wavelength
                    c1 *= wavelength / wvl
                }
                return IrradianceRecord(wvl: wvl, etr: h0, global: dtot * c1, direct: dir * c1, diffuse: dif * c1)
            }
            return IrradianceRecord(wvl: wavelength, etr: h0, global: dtot, direct: dir, diffuse: dif)
        }

        // Calculate total and diffuse energies
        fileprivate func calcEnergies(
            dir: Double, cz: Double,
            dray: Double, daer: Double, drgd: Double, c4: Double,
            rho: Double, h0: Double) -> (dtot: Double, dif: Double) {
            // Equation 3-1
            var dif = (dray + daer + drgd) * c4

            // Global (total) energy
            var dtot = dir * cz + dif

            if orientation.tilt > 1.0e-4 {
                // Tilt energy: Equation 3-18 without the first (direct-beam) term
                let c1 = dtot * rho * (1.0 - ct) / 2.0
                let c2 = dir / h0
                let c3 = dif * c2 * ci / cz
                let c4 = dif * (1.0 - c2) * (1.0 + ct) / 2.0
                dif = c1 + c3 + c4

                // Equation 3-18, including first term
                dtot = dir * ci + dif
            }

            return (dtot: dtot, dif: dif)
        }
    }
}
