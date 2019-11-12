// Description of atmospheric conditions.

// A bit of background on terminology:
//
// Aerosol asymmetry Factor - http://glossary.ametsoc.org/wiki/Asymmetry_factor
// 
// Precipitable water vapor (cm) - http://glossary.ametsoc.org/wiki/Precipitable_water:
// "Total atmospheric water contained in a vertical column of unit
// cross-sectional area extending between any two specified levels, commonly
// expressed in terms of the height to which that water substance would stand
// if completely condensed and collected in a vessel of the same unit cross
// section."

// Aerosol optical depth tau - https://www.esrl.noaa.gov/gmd/grad/surfrad/aod/:
// "particles in the atmosphere (dust, smoke, pollution) can block sunlight by 
// absorbing or by scattering light. AOD tells us how much direct sunlight is 
// prevented from reaching the ground by these aerosol particles. It is a 
// dimensionless number that is related to the amount of aerosol in the
// vertical  column of atmosphere over the observation location.
//
// A value of 0.01 corresponds to an extremely clean atmosphere, and a value of 
// 0.4 would correspond to a very hazy condition. An average aerosol optical
// depth for the U.S. is 0.1 to 0.15."
//
// Ozone absorption - a scaling factor that affects the calculation of light
// attenuation at a given wavelength, given the ozone mass in the atmosphere. 
// This is an optional because a default calculation is available.


public struct AtmosphericConditions {
    var alpha: Double  // power on Angstrom turbidity
    var aerosolAssymetryFactor: Double
    var waterVapor: Double  // Precipitable water vapor (cm)
    var tau500: Double      // Aerosol optical depth at 0.5 microns, base e 
    var temperature: Double
    var pressure: Double
    var ozoneAbsorption: Double? // Ozone absorption factor

    public init(
        alpha a: Double = 1.14,
        aerosolAssymetryFactor aaf: Double = 0.65, // Default to rural
        waterVapor wv: Double,
        tau500 t500: Double = 0.15,
        temperature t: Double = DEFAULT_TEMP,
        pressure p: Double = DEFAULT_PRESSURE,
        ozoneAbsorption oa: Double? = nil)
    {
        alpha = a
        aerosolAssymetryFactor = aaf
        waterVapor = wv
        tau500 = t500
        temperature = t
        pressure = p
        ozoneAbsorption = oa
    }
}
