import Foundation
import SolarPos

// swiftlint:disable identifier_name

// Calculates parameters related to aerosols which I don't understand :)
internal struct AerosolInfo {
    let ozoneMass: Double
    let afs: Double
    let bfs: Double
    let fsp: Double
    let fs: Double

    init(cz: Double, aaf aerosolAssymetryFactor: Double) {
        // Equation 3-14
        let alg = log(1.0 - aerosolAssymetryFactor)

        let ozoneMassIn = 1.003454 / sqrt(pow(cz, 2) + 0.006908)
        // Equation 3-12
        let afsIn = alg * (1.459 + alg * (0.1595 + alg * 0.4129))
        // Equation 3-13
        let bfsIn = alg * (0.0783 + alg * (-0.3824 - alg * 0.5874))
        // Equation 3-15
        let fspIn = 1.0 - 0.5 * exp((afsIn + bfsIn / 1.8) / 1.8)
        // Equation 3-11
        let fsIn = 1.0 - 0.5 * exp((afsIn + bfsIn * cz) * cz)

        ozoneMass = ozoneMassIn
        afs = afsIn
        bfs = bfsIn
        fsp = fspIn
        fs = fsIn
    }
}
