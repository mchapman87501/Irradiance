// These are the types of spectral info that can be calculated by
// Irradiance.
public enum IrradianceResultUnits {
    case irradiance // W/m^2/micron
    case flux // photon flux (10.0e+16 /cm^2/s/micron)
    case fluxDensity // 10.0e+16/cm^2/s/eV
}
