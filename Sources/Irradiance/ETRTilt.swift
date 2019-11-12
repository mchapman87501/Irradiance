import Foundation
import SolarPos

// swiftlint:disable identifier_name

// Extraterrestrial radiation on a tilted surface
internal struct ETRTilt {
    let cosInc: Double // Cosine of the angle between the sun and a tipped flat surface
    let radiation: Double // Extraterrestrial radiation on the tilted surface

    init(solarAzimuth azimuth: Double, orientation: Orientation,
         refract: AtmosphericRefraction, etrNormal: Double) {
        let aspect = orientation.azimuth
        let tilt = orientation.tilt

        let ca = cos(rads(azimuth))
        let cp = cos(rads(aspect))
        let ct = cos(rads(tilt))
        let sa = sin(rads(azimuth))
        let sp = sin(rads(aspect))
        let st = sin(rads(tilt))
        let sz = sin(rads(refract.zenRef))

        let cosInc = refract.cosZen * ct + sz * st * (ca * cp + sa * sp)
        self.cosInc = cosInc
        self.radiation = (cosInc <= 0.0) ? 0.0 : etrNormal * cosInc
    }
}
