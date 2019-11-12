// Represents ground reflectivity values by freq/wavelength.
public struct Reflectivity {
    typealias Values = [Double]
    
    // X values: the wavelength or frequency in each bucket
    let waveOrFreq: Values
    // Ground reflectivity at each wavelength/frequency
    let ground: Values
}

