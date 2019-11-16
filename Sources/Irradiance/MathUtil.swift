public func rads(_ degrees: Double) -> Double {
    return .pi * degrees / 180.0
}

// Linear interpolation across x, with crash on extrapolation :)
// swiftlint:disable identifier_name
public func linterp(x: Double, xvals: [Double], yvals: [Double]) -> Double {
    var i = 1
    while x > xvals[i] {
        i += 1
    }
    let xfract = (x - xvals[i - 1]) / (xvals[i] - xvals[i - 1])
    return xfract * (yvals[i] - yvals[i - 1]) + yvals[i - 1]
}
