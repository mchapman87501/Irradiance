// A "table" of spectral values, organized as parallel arrays:
public struct Spectra {
    public typealias Values = [Double]

    // X values: the wavelength or frequency in each bucket
    let waveOrFreq: Values

    // Varieties of y-values
    let diffuse: Values
    let direct: Values
    let extraterrestrial: Values
    let global: Values
}
