// Describes irradiance for a particular wavelength.

public struct IrradianceRecord {
    // Wavelength or frequency
    // XXX FIX THIS the units for the value are the same as the 
    // Irradiance.Units used to create the Irradiance instance that
    // provided this record.
    public let wvl: Double

    public let etr: Double // Irradiance at top of atmosphere - no refraction
    public let global: Double
    public let direct: Double
    public let diffuse: Double // Diffuse irradiance at waveOrFreq
}

