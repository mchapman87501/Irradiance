import Foundation
import SolarPos // For math utils

// Refraction correction, degrees
// Zimmerman, John C.  1981.  Sun-pointing programs and their
// accuracy.
// SAND81-0761, Experimental Systems Operation Division 4721,
// Sandia National Laboratories, Albuquerque, NM.
internal struct AtmosphericRefraction {
    let elevRef: Double // Refracted solar elevation angle
    let zenRef: Double  // Refracted solar zenith angle
    let cosZen: Double  // cos(zenRef) -- not sure why we need this...

    init(
        elevationETR: Double,
        pressure: Double = DefaultConst.pressure,
        temperature: Double = DefaultConst.temperature) {
        let refcor = AtmosphericRefraction.getRefractionCorrection(
            elevationETR: elevationETR, pressure: pressure, temperature: temperature)

        // Refracted solar elevation angle
        let eref = elevationETR + refcor
        // (limit the degrees below the horizon to 9)
        elevRef = (eref < -9.0) ? -9.0 : eref

        // Refracted solar zenith angle
        zenRef = 90.0 - elevRef
        cosZen = cos(rads(zenRef))
    }

    public static func getRefractionCorrection(
        elevationETR: Double, pressure: Double, temperature: Double) -> Double {
        // If the sun is near zenith, the algorithm bombs; refraction near 0
        guard elevationETR <= 85.0 else { return 0.0 }

        // Otherwise, we have refraction
        let rawRefCorr = getRawRefCorr(elevationETR: elevationETR)
        let pressTemp = getPressTempRatio(pressure: pressure, temperature: temperature)
        return rawRefCorr * pressTemp / 3600.0
    }

    private static func getRawRefCorr(elevationETR: Double) -> Double {
        let tanelev = tan(rads(elevationETR))
        if elevationETR >= 5.0 {
            return 58.1 / tanelev -
                   0.07 / pow(tanelev, 3) +
                   0.000086 / pow(tanelev, 5)
        } else if elevationETR >= -0.575 {
            return 1735.0 +
                   elevationETR * (-518.2 + elevationETR * (103.4 +
                   elevationETR * (-12.79 + elevationETR * 0.711)))
        }
        return -20.774 / tanelev
    }

    private static func getPressTempRatio(
        pressure: Double, temperature celsius: Double) -> Double {
        let kelvin = celsius + 273.0
        return (283.0 * pressure) / (1013 * kelvin)
    }
}
