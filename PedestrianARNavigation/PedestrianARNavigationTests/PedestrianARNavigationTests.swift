//
//  PedestrianARNavigationTests.swift
//  PedestrianARNavigationTests
//
//  Created by Dmitry Trimonov on 18/04/2018.
//  Copyright © 2018 Yandex, LLC. All rights reserved.
//

import XCTest
import CoreLocation
import SceneKit
@testable import PedestrianARNavigation

class PedestrianARNavigationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testTranslationToPosition() {
        let e1 = SceneLocationEstimate.init(location: CLLocation(latitude: 55.768382, longitude: 37.617810), position: SCNVector3Zero)
        let actualLocation1 = e1.translatedLocation(to: SCNVector3Make(240.0, 0.0, 162.0))
        let actualLocation2 = e1.location.coordinate.transform(using: -162.0, longitudinalMeters: 240.0)
        let expectedLocation = CLLocation.init(latitude: 55.766986, longitude: 37.621629)

        let distanceStartToEnd = metersBetween(e1.location.coordinate, expectedLocation.coordinate)
        let distance1 = metersBetween(actualLocation1.coordinate, expectedLocation.coordinate)
        let distance2 = metersBetween(actualLocation2, expectedLocation.coordinate)
        XCTAssert(distance2 < 7.0)
    }

    func testCreatePoints() {
        let positions: [SCNVector3] = [
            SCNVector3(x: 0.0, y: 0.0, z: 0.0),
            SCNVector3(x: 0.0, y: 0.0, z: 0.0),
            SCNVector3(x: 0.0, y: 0.0, z: 0.0),
            SCNVector3(x: 0.0511238575, y: 0.0108033419, z: -0.0306005478),
            SCNVector3(x: 1.12811637, y: -0.0227847695, z: -0.676837921),
            SCNVector3(x: 2.38783336, y: -0.105084702, z: -0.744121075),
            SCNVector3(x: 3.57264924, y: -0.138565525, z: 0.0406835079),
            SCNVector3(x: 4.75106907, y: -0.160424516, z: 1.14971471),
            SCNVector3(x: 5.69589043, y: -0.201014489, z: 2.39373159),
            SCNVector3(x: 6.47676182, y: -0.217762917, z: 3.62756729),
            SCNVector3(x: 7.33403301, y: -0.224274471, z: 5.05949593),
            SCNVector3(x: 8.50009823, y: -0.272066832, z: 7.03640556),
            SCNVector3(x: 9.36685848, y: -0.336183697, z: 8.43552876),
            SCNVector3(x: 10.2866774, y: -0.382574797, z: 9.90880108),
            SCNVector3(x: 11.2067413, y: -0.415676862, z: 11.3919163),
            SCNVector3(x: 12.0712881, y: -0.430284739, z: 12.8515635),
            SCNVector3(x: 13.0651188, y: -0.489033401, z: 14.4371166),
            SCNVector3(x: 14.0266132, y: -0.497165561, z: 16.0471153),
            SCNVector3(x: 14.9149799, y: -0.548061788, z: 17.4903431),
            SCNVector3(x: 15.8206005, y: -0.596293926, z: 18.9709682),
            SCNVector3(x: 16.736145, y: -0.620852709, z: 20.4078312),
            SCNVector3(x: 17.6866531, y: -0.666998625, z: 21.8166733),
            SCNVector3(x: 18.5938873, y: -0.723969936, z: 23.2609882),
            SCNVector3(x: 19.4579639, y: -0.758802533, z: 24.7271214),
            SCNVector3(x: 20.402422, y: -0.801386118, z: 26.19767),
            SCNVector3(x: 21.5574398, y: -0.849786758, z: 27.3014565),
            SCNVector3(x: 23.1633854, y: -0.856470823, z: 27.8634129),
            SCNVector3(x: 24.8110847, y: -1.00718582, z: 28.0576954),
            SCNVector3(x: 26.7339611, y: -0.989329636, z: 28.0892391),
            SCNVector3(x: 28.6494579, y: -0.969361901, z: 28.0746174),
            SCNVector3(x: 30.470623, y: -0.920706153, z: 28.254858),
            SCNVector3(x: 32.1829987, y: -0.940381527, z: 28.4906673),
            SCNVector3(x: 33.8842278, y: -0.972049594, z: 28.8654175),
            SCNVector3(x: 35.5392532, y: -1.00503194, z: 29.509861),
            SCNVector3(x: 36.9347839, y: -1.01851475, z: 30.4418335),
            SCNVector3(x: 38.2729721, y: -1.09341335, z: 31.6008434),
            SCNVector3(x: 39.5607147, y: -1.07207334, z: 32.8547592),
            SCNVector3(x: 40.5218697, y: -0.950648487, z: 34.1699677),
            SCNVector3(x: 41.4342499, y: -0.938070118, z: 35.4970665),
            SCNVector3(x: 42.3995399, y: -0.966735959, z: 36.8262825),
            SCNVector3(x: 43.3817368, y: -1.01860857, z: 38.2481117),
            SCNVector3(x: 44.4579544, y: -1.05739141, z: 39.6884079),
            SCNVector3(x: 45.4509888, y: -1.10671294, z: 41.1424751),
            SCNVector3(x: 46.3961983, y: -1.16199124, z: 42.4766502),
            SCNVector3(x: 47.2614021, y: -1.14959812, z: 43.8486481),
            SCNVector3(x: 48.1140366, y: -1.16843772, z: 45.2836761),
            SCNVector3(x: 49.0498848, y: -1.20563805, z: 46.6762009),
            SCNVector3(x: 49.9454689, y: -1.22132158, z: 48.0969582),
            SCNVector3(x: 50.7931023, y: -1.25844276, z: 49.4969635),
            SCNVector3(x: 51.6408615, y: -1.3001132, z: 50.8880043),
            SCNVector3(x: 52.5230751, y: -1.33237529, z: 52.265522),
            SCNVector3(x: 53.3634644, y: -1.34199202, z: 53.6386223),
            SCNVector3(x: 54.1945534, y: -1.36982465, z: 55.0332642),
            SCNVector3(x: 55.0375786, y: -1.39666915, z: 56.4058228),
            SCNVector3(x: 55.8708763, y: -1.45746541, z: 57.841629),
            SCNVector3(x: 56.7002411, y: -1.49132431, z: 59.2857742),
            SCNVector3(x: 57.6864281, y: -1.55323613, z: 60.6656647),
            SCNVector3(x: 58.5951462, y: -1.58615506, z: 62.0597534),
            SCNVector3(x: 59.3972435, y: -1.59344983, z: 63.5127678),
            SCNVector3(x: 60.243576, y: -1.60077572, z: 64.870163),
            SCNVector3(x: 61.1279831, y: -1.63924789, z: 66.3309097),
            SCNVector3(x: 62.0563812, y: -1.69363713, z: 67.8781357),
            SCNVector3(x: 62.9572906, y: -1.74633467, z: 69.3491287),
            SCNVector3(x: 63.8452454, y: -1.7912302, z: 70.8111343),
            SCNVector3(x: 64.6939697, y: -1.82809305, z: 72.2824173),
            SCNVector3(x: 65.5290604, y: -1.83696473, z: 73.6724396),
            SCNVector3(x: 66.4768143, y: -1.87144256, z: 75.0772095),
            SCNVector3(x: 67.475647, y: -1.89176798, z: 76.4578171),
            SCNVector3(x: 68.5193634, y: -1.93630362, z: 77.9874039),
            SCNVector3(x: 69.5450211, y: -2.00367641, z: 79.6134033),
            SCNVector3(x: 70.6028519, y: -2.02882862, z: 81.175293),
            SCNVector3(x: 71.6924286, y: -2.12097263, z: 82.8234482),
            SCNVector3(x: 72.6633377, y: -2.19917297, z: 84.4235992),
            SCNVector3(x: 73.4870987, y: -2.20721626, z: 86.0125198),
            SCNVector3(x: 74.2875671, y: -2.25030541, z: 87.4459915),
            SCNVector3(x: 75.1510239, y: -2.28537059, z: 88.9156876),
            SCNVector3(x: 75.9501343, y: -2.34592462, z: 90.4072876),
            SCNVector3(x: 76.7574387, y: -2.40087557, z: 91.8425827),
            SCNVector3(x: 77.7174454, y: -2.51764226, z: 93.3175735),
            SCNVector3(x: 78.410759, y: -2.51155806, z: 94.5510559),
            SCNVector3(x: 79.2982025, y: -2.47708035, z: 95.8350449),
            SCNVector3(x: 80.2647629, y: -2.46974349, z: 97.2147522),
            SCNVector3(x: 81.1132202, y: -2.54238582, z: 98.5696869),
            SCNVector3(x: 82.0133896, y: -2.58048201, z: 99.9881516),
            SCNVector3(x: 83.0581589, y: -2.63845444, z: 101.426048),
            SCNVector3(x: 84.1100693, y: -2.74427724, z: 102.868156),
            SCNVector3(x: 84.8720856, y: -2.72800756, z: 104.266228),
            SCNVector3(x: 85.6056366, y: -2.83821154, z: 105.867775),
            SCNVector3(x: 86.4835815, y: -2.87369943, z: 107.439537),
            SCNVector3(x: 87.5138626, y: -2.96358418, z: 109.028427),
            SCNVector3(x: 88.5228271, y: -2.89001298, z: 110.364105),
            SCNVector3(x: 89.2808456, y: -2.763448, z: 111.664062),
            SCNVector3(x: 89.9402161, y: -2.79403353, z: 113.151817),
            SCNVector3(x: 90.7714462, y: -2.82520151, z: 114.635582),
            SCNVector3(x: 91.5416946, y: -2.86283326, z: 116.151398),
            SCNVector3(x: 92.3623047, y: -2.90273476, z: 117.704254),
            SCNVector3(x: 93.3094788, y: -2.94250798, z: 119.296913),
            SCNVector3(x: 94.1851959, y: -2.99738169, z: 120.709137),
            SCNVector3(x: 95.1492615, y: -3.03964353, z: 122.164505),
            SCNVector3(x: 96.0546188, y: -3.03999543, z: 123.649368),
            SCNVector3(x: 97.0476074, y: -3.09980273, z: 125.103012),
            SCNVector3(x: 97.9755554, y: -3.15516472, z: 126.659958),
            SCNVector3(x: 98.9083633, y: -3.22456646, z: 128.18158),
            SCNVector3(x: 99.7525177, y: -3.26436973, z: 129.64769),
            SCNVector3(x: 100.72805, y: -3.2645576, z: 130.970886),
            SCNVector3(x: 101.71553, y: -3.25472522, z: 132.447632),
            SCNVector3(x: 102.643791, y: -3.31884885, z: 133.909027),
            SCNVector3(x: 103.605118, y: -3.37528014, z: 135.477951),
            SCNVector3(x: 104.492363, y: -3.41726327, z: 136.91777),
            SCNVector3(x: 105.365074, y: -3.46153212, z: 138.328552),
            SCNVector3(x: 106.233856, y: -3.48339057, z: 139.64473),
            SCNVector3(x: 107.16658, y: -3.51395988, z: 141.061157),
            SCNVector3(x: 108.059074, y: -3.53845811, z: 142.480164),
            SCNVector3(x: 109.163544, y: -3.53483486, z: 143.786072),
            SCNVector3(x: 110.176704, y: -3.60095572, z: 145.226562),
            SCNVector3(x: 111.154335, y: -3.61962867, z: 146.697418),
            SCNVector3(x: 112.165115, y: -3.69578505, z: 148.181534),
            SCNVector3(x: 113.100891, y: -3.70954728, z: 149.620956),
            SCNVector3(x: 114.038551, y: -3.72651958, z: 151.034073),
            SCNVector3(x: 115.064987, y: -3.75769925, z: 152.431458),
            SCNVector3(x: 116.011223, y: -3.87236166, z: 153.840927),
            SCNVector3(x: 116.954674, y: -3.88586664, z: 155.219437),
            SCNVector3(x: 117.917641, y: -3.9399395, z: 156.574646),
            SCNVector3(x: 118.78064, y: -3.91181469, z: 158.086578),
            SCNVector3(x: 119.64798, y: -3.89502597, z: 159.514389),
            SCNVector3(x: 120.589027, y: -3.93156838, z: 160.957214),
            SCNVector3(x: 121.514336, y: -3.97134447, z: 162.468643),
            SCNVector3(x: 122.489861, y: -4.01669407, z: 163.987411),
            SCNVector3(x: 123.414505, y: -4.03787518, z: 165.464005),
            SCNVector3(x: 124.298149, y: -4.06703186, z: 166.909546),
            SCNVector3(x: 125.22776, y: -4.09182549, z: 168.344421),
            SCNVector3(x: 126.277031, y: -4.10580826, z: 169.782928),
            SCNVector3(x: 127.21888, y: -4.12977648, z: 171.220673),
            SCNVector3(x: 128.143326, y: -4.15789318, z: 172.629868),
            SCNVector3(x: 129.120956, y: -4.2059865, z: 174.057587),
            SCNVector3(x: 130.041992, y: -4.21334887, z: 175.455673),
            SCNVector3(x: 131.024689, y: -4.25616693, z: 176.856888),
            SCNVector3(x: 132.011734, y: -4.2982831, z: 178.227859),
            SCNVector3(x: 133.011108, y: -4.34671402, z: 179.566086),
            SCNVector3(x: 133.789108, y: -4.43118477, z: 181.068939),
            SCNVector3(x: 134.335785, y: -4.53442478, z: 182.667328),
            SCNVector3(x: 134.523621, y: -4.70436239, z: 184.210678),
            SCNVector3(x: 134.680008, y: -4.94367027, z: 185.770782),
            SCNVector3(x: 135.244186, y: -4.99475193, z: 187.325302),
            SCNVector3(x: 135.908127, y: -5.0044837, z: 188.846146),
            SCNVector3(x: 136.531616, y: -5.05126381, z: 190.34819),
            SCNVector3(x: 137.034073, y: -5.06490517, z: 191.899628),
            SCNVector3(x: 137.418381, y: -5.08195734, z: 193.424957),
            SCNVector3(x: 137.655045, y: -5.15127754, z: 195.025269),
            SCNVector3(x: 137.827744, y: -5.2077632, z: 196.662689),
            SCNVector3(x: 137.980392, y: -5.27588892, z: 198.242126),
            SCNVector3(x: 138.171921, y: -5.3845458, z: 199.868881),
            SCNVector3(x: 138.392273, y: -5.4482336, z: 201.468445),
            SCNVector3(x: 139.151535, y: -5.41864824, z: 202.736679),
            SCNVector3(x: 140.51384, y: -5.34411764, z: 203.334732),
            SCNVector3(x: 141.932388, y: -5.15779591, z: 203.37822),
            SCNVector3(x: 143.504181, y: -4.98040247, z: 202.975403),
            SCNVector3(x: 145.091583, y: -4.82479572, z: 202.385941),
            SCNVector3(x: 146.748215, y: -4.69738388, z: 201.877548),
            SCNVector3(x: 148.29155, y: -4.5469017, z: 201.220673),
            SCNVector3(x: 149.78656, y: -4.42737055, z: 200.42099),
            SCNVector3(x: 151.152267, y: -4.25622416, z: 199.715866),
            SCNVector3(x: 152.557175, y: -4.15805817, z: 198.989883),
            SCNVector3(x: 153.906021, y: -4.05046082, z: 198.202454),
            SCNVector3(x: 155.314392, y: -3.94095421, z: 197.388351),
            SCNVector3(x: 156.696121, y: -3.90894437, z: 196.686523),
            SCNVector3(x: 158.189133, y: -3.84081149, z: 195.912094),
            SCNVector3(x: 159.675217, y: -3.80705905, z: 195.045517),
            SCNVector3(x: 161.047852, y: -3.72272301, z: 194.093903),
            SCNVector3(x: 162.021744, y: -3.61242628, z: 192.780548),
            SCNVector3(x: 162.947525, y: -3.58496761, z: 191.252609),
            SCNVector3(x: 164.40979, y: -3.51638818, z: 190.055862),
            SCNVector3(x: 165.956772, y: -3.43183303, z: 189.253281),
            SCNVector3(x: 167.475098, y: -3.36998487, z: 188.381866),
            SCNVector3(x: 168.852188, y: -3.3192749, z: 187.24791),
            SCNVector3(x: 169.956726, y: -3.21936202, z: 185.891983),
            SCNVector3(x: 170.860794, y: -3.16948915, z: 184.355957),
            SCNVector3(x: 171.744583, y: -3.11445045, z: 182.737366),
            SCNVector3(x: 172.559052, y: -3.08432221, z: 181.187988),
            SCNVector3(x: 173.320419, y: -3.02786255, z: 179.597153),
            SCNVector3(x: 174.148819, y: -2.96375561, z: 178.009308),
            SCNVector3(x: 174.95668, y: -2.89163303, z: 176.409515),
            SCNVector3(x: 175.743835, y: -2.83916712, z: 174.822098),
            SCNVector3(x: 176.486542, y: -2.70427799, z: 173.272446),
            SCNVector3(x: 177.192474, y: -2.617625, z: 171.71048),
            SCNVector3(x: 177.969864, y: -2.54247522, z: 170.188568),
            SCNVector3(x: 178.803604, y: -2.47871828, z: 168.628662),
            SCNVector3(x: 179.465805, y: -2.40311718, z: 167.088974),
            SCNVector3(x: 180.103226, y: -2.37520981, z: 165.577393),
            SCNVector3(x: 180.920639, y: -2.24978185, z: 164.103378),
            SCNVector3(x: 181.740097, y: -2.17361259, z: 162.57663),
            SCNVector3(x: 182.502487, y: -2.12239432, z: 161.045288),
            SCNVector3(x: 183.313782, y: -2.04746389, z: 159.534836),
            SCNVector3(x: 184.049072, y: -2.00860763, z: 158.121902),
            SCNVector3(x: 184.756927, y: -1.9319104, z: 156.66893),
            SCNVector3(x: 185.475723, y: -1.85344493, z: 155.116394),
            SCNVector3(x: 186.14386, y: -1.80293429, z: 153.59169),
            SCNVector3(x: 186.822113, y: -1.70900166, z: 151.97998),
            SCNVector3(x: 187.496689, y: -1.63147414, z: 150.273392),
            SCNVector3(x: 188.214401, y: -1.56112218, z: 148.691132),
            SCNVector3(x: 189.044907, y: -1.50006652, z: 147.137039),
            SCNVector3(x: 189.778885, y: -1.46208119, z: 145.639938),
            SCNVector3(x: 190.385849, y: -1.33150375, z: 144.143204),
            SCNVector3(x: 191.103424, y: -1.28719521, z: 142.579269),
            SCNVector3(x: 191.948959, y: -1.18927598, z: 141.029236),
            SCNVector3(x: 192.692749, y: -1.12754893, z: 139.619202),
            SCNVector3(x: 193.381577, y: -1.0632689, z: 138.121994),
            SCNVector3(x: 194.01796, y: -0.979658604, z: 136.683197),
            SCNVector3(x: 194.558411, y: -0.883997083, z: 135.245041),
            SCNVector3(x: 194.736008, y: -0.778612018, z: 133.748489),
            SCNVector3(x: 194.642319, y: -0.709351897, z: 132.272888),
            SCNVector3(x: 194.356323, y: -0.677796602, z: 130.869476),
            SCNVector3(x: 193.88562, y: -0.65753454, z: 129.652374),
            SCNVector3(x: 193.346573, y: -0.57305932, z: 128.545914),
            SCNVector3(x: 192.983398, y: -0.52422142, z: 127.798233),
            ]

        print(positions.count)
        let rotated = positions.map { $0.rotatedClockwise(byAngle: -.pi / 30) }
        let firstEstimate = SceneLocationEstimate(location: CLLocation(latitude: 55.73418251, longitude: 37.58966633), position: SCNVector3Make(0, 0, 0))
        let relativeLocations = rotated.map { firstEstimate.translatedLocation(to: $0) }

        for (index, relLocation) in relativeLocations.enumerated() {
            print("{point: [\(relLocation.coordinate.lat), \(relLocation.coordinate.lon)], accuracy: \(relLocation.horizontalAccuracy)},")
        }

        print(relativeLocations.count)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
