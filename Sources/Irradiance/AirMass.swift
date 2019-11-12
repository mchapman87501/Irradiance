import Foundation
import SolarPos // For math utils

// Airmass
// Kasten, F. and Young, A.  1989.  Revised optical air mass
// tables and approximation formula.  Applied Optics 28 (22),
// pp. 4735-4738
internal struct AirMass {
    let airmass: Double
    let pressure: Double // air mass corrected for atmospheric pressure

    init(zenRef: Double, pressure: Double = DEFAULT_PRESSURE) {
        if zenRef > 93.0 {
            self.airmass = -1.0
            self.pressure = -1.0
        } else {
            let amass = 1.0 / (cos(rads(zenRef)) + 0.50572 * pow((96.07995 - zenRef), -1.6364))
            self.airmass = amass
            self.pressure = amass * pressure / 1013.0
        }
    }
}

