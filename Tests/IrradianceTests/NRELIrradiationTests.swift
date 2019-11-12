import Foundation
import XCTest
@testable import SolarPos
@testable import Irradiance

// Expected results differ from those in the spectest.c printf calls.
// Visual inspection shows that the shapes of the result curves match
// closely.  I believe differences are due to slight differences in
// calculated sun angles resulting from the use of different angle
// calculation algorithms, from the 2008 paper.
// See Tests/ActualVsExpectedResults.numbers

struct Expected {
    static let wvl = [
        0.3, 0.305, 0.31, 0.315, 0.32, 0.325, 0.33, 0.335, 0.34, 
        0.345, 0.35, 0.36, 0.37, 0.38, 0.39, 0.4, 0.41, 0.42, 0.43, 
        0.44, 0.45, 0.46, 0.47, 0.48, 0.49, 0.5, 0.51, 0.52, 0.53, 
        0.54, 0.55, 0.57, 0.593, 0.61, 0.63, 0.656, 0.6676, 0.69, 
        0.71, 0.718, 0.7244, 0.74, 0.7525, 0.7575, 0.7625, 0.7675, 
        0.78, 0.8, 0.816, 0.8237, 0.8315, 0.84, 0.86, 0.88, 0.905, 
        0.915, 0.925, 0.93, 0.937, 0.948, 0.965, 0.98, 0.9935, 1.04, 
        1.07, 1.1, 1.12, 1.13, 1.145, 1.161, 1.17, 1.2, 1.24, 1.27, 
        1.29, 1.32, 1.35, 1.395, 1.4425, 1.4625, 1.477, 1.497, 1.52, 
        1.539, 1.558, 1.578, 1.592, 1.61, 1.63, 1.646, 1.678, 1.74, 
        1.8, 1.86, 1.92, 1.96, 1.985, 2.005, 2.035, 2.065, 2.1, 
        2.148, 2.198, 2.27, 2.36, 2.45, 2.5, 2.6, 2.7, 2.8, 2.9, 
        3, 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8, 3.9, 4, 
    ]

    static let etr = [
        544.48, 567.24, 631.96, 703.79, 726.55, 846.24, 977.3, 946.82, 
        915.02, 925.89, 991.12, 991.53, 1137.8, 1121.5, 1050.4, 
        1502.8, 1728.5, 1768.3, 1612.6, 1866.4, 2037.1, 2075.7, 
        2018.8, 2059.5, 1926.4, 1939.6, 1957.9, 1860.3, 1921.3, 
        1928.4, 1922.3, 1869.5, 1796.3, 1755.7, 1684.5, 1548.4, 
        1555.5, 1442.7, 1421.4, 1396, 1395, 1318.8, 1289.3, 1264.9, 
        1242.6, 1224.3, 1201.9, 1166.4, 1108.5, 1079, 1054.6, 1038.4, 
        1014.7, 962.37, 907.5, 882.1, 842.98, 843.59, 827.03, 799.5, 
        780.6, 779.28, 769.73, 699.12, 650.96, 615.91, 595.28, 579.33, 
        573.13, 552.91, 541.94, 509.63, 485.15, 449.79, 447.04, 
        423.47, 397.67, 364.65, 332.74, 322.58, 312.22, 305.21, 
        297.49, 279.91, 276.46, 263.45, 250.85, 247.91, 247.4, 238.56, 
        224.03, 193.85, 173.84, 146.81, 137.87, 124.97, 125.78, 
        114.81, 110.24, 99.061, 93.879, 83.719, 75.794, 69.394, 
        64.822, 50.293, 49.277, 39.218, 37.186, 32.512, 28.55, 25.197, 
        22.454, 19.914, 17.78, 15.951, 14.326, 12.903, 11.684, 10.567, 
        9.6521, 8.7377, 
    ]

    static let global = [
        2.7992, 27.346, 77.253, 159.21, 216.18, 313.2, 412.3, 428.83, 
        434.75, 458.08, 507.92, 539, 650.79, 671.67, 655.84, 974.34, 
        1159.5, 1223.2, 1146.9, 1361.3, 1518.1, 1568.6, 1544.7, 
        1592, 1501.4, 1521.2, 1543.1, 1473.5, 1523.5, 1531.8, 1530.1, 
        1482.1, 1413.2, 1416.7, 1386.9, 1298.6, 1316.4, 1149.4, 
        1225.3, 1072.2, 1048.1, 1133.3, 1128.8, 1109, 712.59, 962.48, 
        1059.7, 1019.5, 875.23, 825.68, 881.03, 894.22, 901.55, 
        855.33, 625.36, 635.29, 607.51, 439.37, 333.64, 350.54, 
        577.96, 625.4, 673.78, 626.88, 584.01, 468.69, 163.82, 211.3, 
        202.04, 364.73, 394.56, 403.94, 421.46, 366.59, 386.52, 
        316.9, 72.666, 6.9879, 62.912, 109.51, 106.66, 196.03, 261.25, 
        251.2, 235.04, 231.15, 218.25, 210.92, 223.54, 214.71, 200.72, 
        160.47, 44.815, 2.8401, 8.9977, 24.858, 87.669, 31.82, 86.372, 
        70.47, 78.525, 73.06, 65.78, 59.444, 48.957, 17.497, 5.9412, 
        1.4461e-06, 2.2608e-09, 8.4327e-06, 1.179, 3.9263, 3.6823, 
        5.1819, 3.7216, 7.497, 10.51, 9.9175, 9.2288, 8.6575, 7.7669, 
        7.791, 
    ]

    static let direct = [
        0.97084, 10.269, 31.032, 67.678, 96.798, 146.8, 201.53, 
        217.94, 228.96, 249.15, 284.45, 317.62, 400.12, 427.97, 
        430.77, 656.89, 799.59, 860.34, 820.9, 989.49, 1118.9, 1177, 
        1178.1, 1232.6, 1178.6, 1209.5, 1241.5, 1198.5, 1252, 1271, 
        1280.9, 1261.3, 1223.4, 1238.2, 1225.3, 1161.9, 1183.9, 
        1046.7, 1120.9, 988.46, 969.14, 1048, 1047.3, 1030.5, 672.38, 
        900.83, 991.2, 959.2, 829.79, 785.04, 836.85, 850.19, 860.11, 
        819.46, 606.36, 616.42, 590.47, 430.27, 328.35, 345.15, 
        565.02, 611.58, 658.71, 616.45, 576.48, 466.01, 165.27, 
        212.89, 203.89, 365.84, 395.43, 405.31, 423.6, 369.8, 390.08, 
        321.32, 74.649, 7.2162, 64.924, 112.83, 109.96, 201.25, 
        267.42, 257.29, 241.17, 237.29, 224.22, 216.93, 229.92, 
        221.01, 206.9, 165.98, 46.803, 2.9792, 9.4467, 26.083, 91.52, 
        33.393, 90.19, 73.699, 82.077, 76.419, 68.883, 62.347, 51.484, 
        18.492, 6.2945, 1.5352e-06, 2.4025e-09, 8.9694e-06, 1.2548, 
        4.1792, 3.9223, 5.5206, 3.9686, 7.989, 11.192, 10.566, 9.8373, 
        9.2323, 8.2876, 8.3145, 
    ]

    static let diffuse = [
        1.9133, 17.975, 48.935, 97.453, 127.85, 179.24, 228.39, 
        229.95, 225.82, 230.72, 248.34, 249.16, 285.66, 281.12, 
        262.74, 374.89, 429.81, 438.05, 397.82, 458.34, 497.1, 494.52, 
        469.56, 467.23, 425.89, 417.51, 410.2, 379.79, 380.96, 372, 
        361.21, 331.07, 296.77, 286.82, 268.75, 238.27, 236.02, 
        194.16, 202.42, 170.22, 163.66, 176.91, 173.04, 168.57, 
        99.007, 140.42, 155.17, 144.15, 118.01, 109.29, 117.36, 
        118.37, 116.66, 107.53, 72.019, 72.775, 68.671, 46.716, 
        34.005, 35.572, 62.346, 67.301, 72.674, 64.335, 57.935, 
        43.428, 13.003, 17.027, 15.978, 30.877, 33.708, 34.076, 
        34.902, 29.13, 30.55, 23.683, 4.5447, 0.40275, 3.6653, 6.549, 
        6.3135, 12.377, 17.214, 16.402, 14.965, 14.609, 13.636, 
        12.955, 13.721, 13.028, 11.914, 9.0082, 2.105, 0.1214, 0.37709, 
        1.0557, 4.1514, 1.3473, 4.0684, 3.2155, 3.6254, 3.3235, 
        2.9201, 2.5483, 1.9749, 0.62215, 0.19714, 4.5175e-08, 6.8419e-11, 
        2.4766e-07, 0.033937, 0.11253, 0.10299, 0.144, 0.10002, 
        0.20658, 0.29675, 0.27548, 0.25179, 0.2325, 0.20398, 0.20357, 
    ]
}


class NRELIrradiationTests: XCTestCase {
    // Mimic some pieces of the original C spectest.c.
    private func eq(_ actual: Double, _ expected: Double, _ failureMsg: String) -> Bool {
        let absErr = abs(actual - expected)
        let fractErr = (expected > 1.0e-9) ? absErr / abs(expected) : absErr
        let maxFractErr = 1.0e-3
        let result = (fractErr <= maxFractErr)
        if !result {
            let stderr = FileHandle.standardError
            if let data = "\(failureMsg): \(actual) != \(expected)\n".data(using: .utf8) {
                stderr.write(data)
            }
        }
        return result
    }
    
    func testIrradiance() throws {
        let ts = TimeSpec(
            year: 1999, month: 7, day: 22, 
            hour: 9, minute: 45, second: 37, gmtOffset: -5)
        
        let latitude = 33.65
        let location = Location(lat: latitude, lon: -84.43)
        let orientation = Orientation(tilt: latitude, azimuth: 135.0)
        
        let atmos = AtmosphericConditions(
            waterVapor: 1.36, tau500: 0.2, temperature: 27.0,
            pressure: 1006.0)
        let irradiance = try Irradiance(
            timespec: ts, location: location, orientation: orientation,
            atmos: atmos, outputUnits: .irradiance)
        
        // This was originally written to compare against results from 
        // specdump.c.  Hence use of istride. 
        var i = 0
        let istride = 1
        var success = true
        for j in 0 ..< Expected.wvl.count {
            let act = irradiance.spectra[i]
            success = eq(act.wvl, Expected.wvl[j], "Wvl[\(i)]") && success
            success = eq(act.etr, Expected.etr[j], "ETR[\(i)]") && success
            success = eq(act.global, Expected.global[j], "Global[\(i)]") && success
            success = eq(act.direct, Expected.direct[j], "Direct[\(i)]") && success
            success = eq(act.diffuse, Expected.diffuse[j], "Diffuse[\(i)]") && success
            
            i += istride
        }
        XCTAssertTrue(success)
    }
    
    // This is derived from NREL's stest00.  It should perhaps be moved to
    // a separate module?
    func testSTest00() throws {
        let ts = TimeSpec(year: 1999, month: 7, day: 22,
                          hour: 9, minute: 45, second: 37, gmtOffset: -5)
        let julian = try JulianDay(timespec: ts)
        let daynum = try julian.getDayNum()
        XCTAssertEqual(daynum, 203)
        
        let latitude = 33.65
        let location = Location(lat: 33.65, lon: -84.43)
        let orientation = Orientation(tilt: latitude, azimuth: 135.0 /* southeast */)
        let temperature = 27.0
        let pressure = 1006.0
        
        let info = try IrradianceConditions(
            timespec: ts, location: location, orientation: orientation,
            temperature: temperature, pressure: pressure
        )
        
        XCTAssertEqual(info.topoAngles.localHourAngle, -44.635081,
                       accuracy: 1.0e-6, "Local hour angle")
        
        XCTAssertEqual(info.zenETR.elev, 48.392867,
                       accuracy: 1.0e-6, "elevation ETR")
        XCTAssertEqual(info.refract.zenRef, 41.593718,
                       accuracy: 1.0e-6, "Refracted Zenith")
        
        XCTAssertEqual(info.airmass.airmass, 1.335827,
                       accuracy: 1.0e-6, "Airmass")
        XCTAssertEqual(info.airmass.pressure, 1.326596,
                       accuracy: 1.0e-6, "Air pressure")
    }
    
    
    
    static var allTests = [
        ("testIrradiance", testIrradiance),
        ("testSTest00", testSTest00)
    ]
}
