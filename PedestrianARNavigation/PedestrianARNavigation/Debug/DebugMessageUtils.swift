//
//  DebugMessageUtils.swift
//  PedestrianARNavigation
//
//  Created by Dmitry Trimonov on 18/04/2018.
//  Copyright © 2018 Yandex, LLC. All rights reserved.
//

import Foundation

func createMessage(from debugRouteInfo: DebugRouteInfo) -> String {

    let debugEstimates = debugRouteInfo.debugEstimates
    let bestEstimates = debugRouteInfo.bestEstimates
    var coreLocationStr = "var coreLocationPoints = [\n"
    for e in debugEstimates {
        let estimateStr = "{point: [\(e.estimateCLLocation.coordinate.lat), \(e.estimateCLLocation.coordinate.lon)], accuracy: \(e.estimateCLLocation.horizontalAccuracy)},\n"
        coreLocationStr.append(estimateStr)
    }
    coreLocationStr.append("\n]")

    var arStr = "var arPoints = [\n"
    for e in debugEstimates {
        let estimateStr = "{point: [\(e.estimateARLocation.coordinate.lat), \(e.estimateARLocation.coordinate.lon)], accuracy: \(e.estimateARLocation.horizontalAccuracy)},\n"
        arStr.append(estimateStr)
    }
    arStr.append("\n]")

    var relativeToStartStr = "var relToStartPoints = [\n"
    for e in debugEstimates {
        let estimateStr = "{point: [\(e.estimateLocationRelativeToStart.coordinate.lat), \(e.estimateLocationRelativeToStart.coordinate.lon)], accuracy: \(e.estimateLocationRelativeToStart.horizontalAccuracy)},\n"
        relativeToStartStr.append(estimateStr)
    }
    relativeToStartStr.append("\n]")

    var bestEstimatesStr = "var bestEstimates = [\n"
    for e in bestEstimates {
        let estimateStr = "[SLE location: \(e.location), position: \(e.position)]\n"
        bestEstimatesStr.append(estimateStr)
    }
    bestEstimatesStr.append("\n]")

    var estimatesStr = "var estimates = [\n"
    for e in debugEstimates {
        let estimateStr = "[SLE location: \(e.estimate.location), position: \(e.estimate.position)]\n"
        estimatesStr.append(estimateStr)
    }
    estimatesStr.append("\n]")

    return estimatesStr + "\n" + coreLocationStr + "\n" + arStr + "\n" + relativeToStartStr + "\n" + bestEstimatesStr
}
