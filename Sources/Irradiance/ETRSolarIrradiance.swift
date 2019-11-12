// Extraterrestrial (top-of-atmosphere) solar irradiance
internal struct ETSolarIrradiance {
    let etr: Double
    let etrNormal: Double

    /**
     * - parameters:
     *    - cosZen: 
     *    - r: distance from earth to sun, (units?)
     *    - solarConstant: solar energy per unit area, W / m^2
     */
    init(cosZen: Double, r earthRadiusVector: Double,
         solarConstant: Double = DefaultConst.solarConstant) {
        if cosZen > 0.0 {
            let etrn = solarConstant * earthRadiusVector
            etrNormal = etrn
            etr = etrn * cosZen
        } else {
            etrNormal = 0.0
            etr = 0.0
        }
    }
}
