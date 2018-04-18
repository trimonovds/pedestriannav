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
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
