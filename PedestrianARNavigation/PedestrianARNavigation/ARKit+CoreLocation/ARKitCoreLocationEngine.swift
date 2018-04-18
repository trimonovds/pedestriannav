//
//  LocationTranslationEngine.swift
//  UserLocationPlacemarkHelper
//
//  Created by Dmitry Trimonov on 03/04/2018.
//  Copyright © 2018 Yandex, LLC. All rights reserved.
//

import Foundation
import CoreLocation
import SceneKit
import ARKit

struct DebugRouteInfo {
    var debugEstimates: [DebugRouteInfoHolder.DebugEsimate]
    var bestEstimates: [SceneLocationEstimate]
}

protocol ARKitCoreLocationEngine {
    /// Converts geo coordinate to 3D position
    ///
    /// - Parameter coordinate: position on earth
    /// - Returns: position on 3D scene with y = 0
    func convert(coordinate: CLLocationCoordinate2D) -> SCNVector3?
    func userLocationEstimate() -> SceneLocationEstimate?

    var debugRouteInfo: DebugRouteInfo { get }

    func refreshDebugInfo()
}

class ARKitCoreLocationEngineImpl: NSObject, ARKitCoreLocationEngine {

    var debugRouteInfo: DebugRouteInfo {
        return DebugRouteInfo(
            debugEstimates: debugRouteInfoHolder.debugEsimates,
            bestEstimates: debugRouteInfoHolder.bestEstimates
        )
    }

    init(view: SCNView, locationManager: LocationManager, locationEstimatesHolder: LocationEstimatesHolder) {
        self.scnView = view
        self.locationManager = locationManager
        self.locationEstimatesHolder = locationEstimatesHolder
        super.init()

        locationEstimatesHolder.addListener(self)
        filterLocationEstimatesAction = TimerAction(timeInterval: 3.0, repeats: true) { [weak self] in
            self?.filterLocationEstimates()
        }

        if let currentLocation = NativeLocationManager.sharedInstance.location {
            self.onLocationUpdate(currentLocation)
        }
        locationManager.addListener(self)
    }

    func userLocationEstimate() -> SceneLocationEstimate? {
        guard let bestEstimate = locationEstimatesHolder.bestLocationEstimate else { return nil }
        guard let position = currentScenePosition() else { return nil }
        let correctLocation = bestEstimate.translatedLocation(to: position)
        return SceneLocationEstimate(location: correctLocation, position: position)
    }

    func convert(coordinate: CLLocationCoordinate2D) -> SCNVector3? {
        guard let anchorEstimate = locationEstimatesHolder.bestLocationEstimate else { return nil }
        let location = anchorEstimate.location
        let position = anchorEstimate.position
        let translation = location.coordinate.translation(toCoordinate: coordinate)
        return SCNVector3(
            x: position.x + Float(translation.longitudeTranslation),
            y: 0.0,
            z: position.z - Float(translation.latitudeTranslation)
        )
    }

    func refreshDebugInfo() {
        debugRouteInfoHolder.refresh()
    }

    private let scnView: SCNView
    private let locationManager: LocationManager
    private let locationEstimatesHolder: LocationEstimatesHolder
    private var filterLocationEstimatesAction: TimerAction? = nil
    private let debugRouteInfoHolder: DebugRouteInfoHolder = DebugRouteInfoHolder()
}

extension ARKitCoreLocationEngineImpl {
    private func currentScenePosition() -> SCNVector3? {
        return scnView.pointOfView?.worldPosition
    }

    private func currentEulerAngles() -> SCNVector3? {
        return scnView.pointOfView?.eulerAngles
    }

    /// Filters locationEstimates
    func filterLocationEstimates() {
        guard let positionOnScene = currentScenePosition() else { return }
        let currentPoint = CGPoint(position: positionOnScene)
        locationEstimatesHolder.filter {
            let point = CGPoint(position: $0.position)
            return currentPoint.radiusContainsPoint(radius: Constants.sceneRadiusLimit, point: point)
        }
    }
}

extension ARKitCoreLocationEngineImpl: LocationEstimatesHolderListener {
    func locationEstimatesHolder(_ locationEstimatesHolder: LocationEstimatesHolder, didUpdateBestEstimate bestEstimate: SceneLocationEstimate) {
        debugRouteInfoHolder.addBestEstimate(bestEstimate)
    }
}

extension ARKitCoreLocationEngineImpl: LocationManagerListener {
    func onAuthorizationStatusUpdate(_ authorizationStatus: CLAuthorizationStatus) {
        
    }

    func onLocationUpdate(_ location: CLLocation) {
        guard let positionOnScene = currentScenePosition() else { return }
        let newLocationEstimate = SceneLocationEstimate(location: location, position: positionOnScene)
        locationEstimatesHolder.add(newLocationEstimate)

        // Add debug info
        guard let userLocationEstimate = userLocationEstimate() else { return }
        let locationRelativeToStart: CLLocation
        if let firstDebugEstimate = debugRouteInfoHolder.debugEsimates.first {
            locationRelativeToStart = firstDebugEstimate.estimate.translatedLocation(to: positionOnScene)
        } else {
            locationRelativeToStart = location
        }
        let debugEstimate = DebugRouteInfoHolder.DebugEsimate(
            estimate: newLocationEstimate,
            estimateARLocation: userLocationEstimate.location,
            estimateLocationRelativeToStart: locationRelativeToStart
        )
        debugRouteInfoHolder.addEstimate(debugEstimate)
    }
}
