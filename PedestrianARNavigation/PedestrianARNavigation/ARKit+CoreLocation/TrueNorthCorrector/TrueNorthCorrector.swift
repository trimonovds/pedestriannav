//
//  TrueNorthCorrector.swift
//  UserLocationPlacemarkHelper
//
//  Created by Dmitry Trimonov on 09/04/2018.
//  Copyright © 2018 Yandex, LLC. All rights reserved.
//

import Foundation

func arVector(_ e1: SceneLocationEstimate, _ e2: SceneLocationEstimate) -> Vector2 {
    let scale = LatLonRatio.metersInOneLatDegree /  LatLonRatio.metersInOneLonDegree(lat: e1.location.coordinate.lat)

    //Dont divise to metersInOneLonLatDegree to avoid small numbers after division because we use float type
    return Vector2(
        Float(e2.position.x - e1.position.x) * Float(scale),
        -Float(e2.position.z - e1.position.z))
}

public func correctionAngleInProd(_ e1: SceneLocationEstimate, _ e2: SceneLocationEstimate) -> Double {
    let arVec = arVector(e1, e2)
    let locationVec = Vector2(
        Float(e2.location.coordinate.lon - e1.location.coordinate.lon),
        Float(e2.location.coordinate.lat - e1.location.coordinate.lat)
    )
    return Double(arVec.angle(with: locationVec).radiansToDegrees)
}

public func correctionAngleByBearing(_ e1: SceneLocationEstimate, _ e2: SceneLocationEstimate) -> Double {
    let calculatedE2Location = e1.translatedLocation(to: e2.position)
    return bearingBetween(e1.location.coordinate, calculatedE2Location.coordinate) - bearingBetween(e1.location.coordinate, e2.location.coordinate)
}

public func correctionAngleEstimate(_ e1: SceneLocationEstimate, _ e2: SceneLocationEstimate) -> Double {
    let calculatedE2Location = e1.translatedLocation(to: e2.position)
    let locationVec = Vector2(
        Float(e2.location.coordinate.lon - e1.location.coordinate.lon),
        Float(e2.location.coordinate.lat - e1.location.coordinate.lat)
    )
    let locationVecCalc = Vector2(
        Float(calculatedE2Location.coordinate.lon - e1.location.coordinate.lon),
        Float(calculatedE2Location.coordinate.lat - e1.location.coordinate.lat)
    )
    return Double(locationVecCalc.angle(with: locationVec).radiansToDegrees)
}

