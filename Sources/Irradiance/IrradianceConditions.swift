// Describes conditions for an Irradiance calculation.
// Used only by Irradiance.

import Foundation
import SolarPos

internal struct IrradianceConditions {
    let daynum: UInt
    let helioPos: HelioPosition
    let geoPos: GeocentricPosition
    let nutation: Nutations
    let obliq: ObliquityOfEcliptic
    let apparentSunLon: Double
    let geoSunAngles: GeocentricSunAngles
    let topoAngles: TopocentricAngles
    let zenETR: ZenithETR
    let refract: AtmosphericRefraction
    let airmass: AirMass
    
    let incidenceAngle: Double
    let irradiance: ETSolarIrradiance
    let etrTilt: ETRTilt  // Extraterrestrial irradiance on the tilted panel
    
    init(
        timespec: TimeSpec, location: Location, orientation: Orientation,
        temperature:Double, pressure:Double) throws 
    {
        let julian = try JulianDay(timespec: timespec)
        let daynum = try julian.getDayNum()
        
        let helioPos = HelioPosition(jme: julian.jme)
        let geoPos = GeocentricPosition(helioPos)
        let nutation = Nutations(jce: julian.jce)
        let obliq = ObliquityOfEcliptic(jme: julian.jme, nutations: nutation)
        let apparentSunLon = apparentSunLongitude(
            lon: geoPos.longitude, nl: nutation.longitude,
            r: helioPos.radius)
        let ast = apparentSiderealTime(
            jd: julian.julianDay, jc: julian.jc, nl: nutation.longitude, 
            trueObliq: obliq.trueObliq)
        let geoSunAngles = GeocentricSunAngles(
            apparentSunLongitude: apparentSunLon,
            meanObliquity: obliq.trueObliq,
            geocentricLatitude: geoPos.latitude)
        let topoAngles = TopocentricAngles(
            apparentSiderealTime: ast, 
            observerLocation: location, geoSunAngles: geoSunAngles, r: helioPos.radius,
            temperature: temperature, pressure: pressure)
        
        // Is this redundant wrt ETRTilt?
        let incidenceAngle = topoAngles.getSurfaceIncidenceAngle(panel: orientation)
        
        // Start calculating irradiance per NREL software
        let zenETR = ZenithETR(
            declination: geoSunAngles.declination, 
            hourAngle: topoAngles.localHourAngle,
            latitude: location.latitude)

        // let sunsetHourAngle = getSunsetHourAngle(
        //     declination: geoSunAngles.declination, latitude: location.latitude)
        //
        // let shadowBandCorr = getShadowBandCorrection(
        //     declination: geoSunAngles.declination, latitude: location.latitude,
        //     sunsetHourAngle: sunsetHourAngle)
        //
        // let tst = TrueSolarTime(
        //     hourAngle: topocentricAngles.localHourAngle,
        //     hour: Double(time.hour), minute: Double(time.minute),
        //     second: Double(time.second), gmtOffset: time.gmtOffset,
        //     longitude: location.longitude)
        //
        // let srss = SunriseSunset(sunsetHourAngle: sunsetHourAngle, tstFix: tst.tstFix)
        
        let refract = AtmosphericRefraction(
            elevationETR: zenETR.elev,
            pressure: pressure, temperature: temperature)

        let airmass = AirMass(zenRef:refract.zenRef, pressure: pressure)

        // let prime = KTPrimeFactors(airmass: airmass.airmass)

        let irradiance = ETSolarIrradiance(
            cosZen: refract.cosZen, r: helioPos.radius)

        let etrTilt = ETRTilt(
            solarAzimuth: topoAngles.azimuthAngle, 
            orientation: orientation, refract: refract,
            etrNormal: irradiance.etrNormal)

        self.daynum = daynum
        self.helioPos = helioPos
        self.geoPos = geoPos
        self.nutation = nutation
        self.obliq = obliq
        self.apparentSunLon = apparentSunLon
        self.geoSunAngles = geoSunAngles
        self.topoAngles = topoAngles
        self.incidenceAngle = incidenceAngle
        self.zenETR = zenETR
        self.refract = refract
        self.airmass = airmass
        self.irradiance = irradiance
        self.etrTilt = etrTilt
    }
}
