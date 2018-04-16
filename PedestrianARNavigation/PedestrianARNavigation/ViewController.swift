//
//  ViewController.swift
//  PedestrianARNavigation
//
//  Created by Dmitry Trimonov on 16/04/2018.
//  Copyright © 2018 Yandex, LLC. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import CoreLocation

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!

    func update(withDestination destination: CLLocationCoordinate2D) {
        guard let currentLocation = engine.userLocationEstimate()?.location else { return }
        let coord = currentLocation.coordinate
        let geoRoute: [CLLocationCoordinate2D] = [
            coord,
            CLLocationCoordinate2D(latitude: coord.latitude + 0.0001, longitude: coord.longitude - 0.00005),
            CLLocationCoordinate2D(latitude: coord.latitude + 0.00006, longitude: coord.longitude - 0.00007),
            CLLocationCoordinate2D(latitude: coord.latitude + 0.00002, longitude: coord.longitude - 0.0001),
            destination
            ]
        let route = geoRoute
            .map { engine.convert(coordinate: $0) }
            .flatMap { $0 }
            .map { CGPoint(position: $0) }

        guard route.count == geoRoute.count else {
            return
        }

        polylineNodes = createPolyline(forRoute: route, withAnimationLength: Constants.distanceBetweenArrows)
        let representation = createRepresentation(forRoute: route, withAnimationLength: Constants.distanceBetweenArrows)
        routePointNodes = representation.routeNodes


        guard let routeFinishPoint = route.last else { return }

        // Create route finish node

        routeFinishNode = RouteFinishNode(radius: 0.0, color: UIColor.green)
        routeFinishNode?.position = routeFinishPoint.positionIn3D

        // Create route finish node hint

        routeFinishHint = makeFinishNodeHint()
    }


    @objc func onRouteUISwitchValueChanged(_ sender: UISwitch) {
        polylineNodes.forEach { $0.isHidden = !sender.isOn }
        routeFinishNode?.isHidden = !sender.isOn
        routeFinishHint?.isHidden = !sender.isOn
    }

    @objc func onRoutePointsSwitchValueChanged(_ sender: UISwitch) {
        routePointNodes.forEach { $0.isHidden = !sender.isOn }
    }

    @objc func onSetDestinationTapped() {
        let mapVc = MapViewController()
        mapVc.delegate = self
        self.present(mapVc, animated: true, completion: nil)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene

        sceneView.showsStatistics = false
        sceneView.debugOptions = []
        sceneView.automaticallyUpdatesLighting = true

        let axises: SCNNode = RouteGeometryFactory.axesNode(quiverLength: 1.0, quiverThickness: 0.5)
        scene.rootNode.addChildNode(axises)

        // Buttons

        setDestinationButton.setTitle("Set Destination", for: .normal)
        setDestinationButton.addTarget(self, action: #selector(onSetDestinationTapped), for: .touchUpInside)
        [setDestinationButton].forEach {
            $0.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            $0.setTitleColor(UIColor.white, for: .normal)
        }

        routeUILabel.text = "Route UI"
        routePointsLabel.text = "Route"

        routeUISwitch.addTarget(self, action: #selector(onRouteUISwitchValueChanged), for: .valueChanged)
        routePointsSwitch.addTarget(self, action: #selector(onRoutePointsSwitchValueChanged), for: .valueChanged)

        let settingsViews: [UIView] = [setDestinationButton, routeUILabel, routeUISwitch, routePointsLabel, routePointsSwitch]

        settingsViews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }



        [routeUILabel, routePointsLabel].forEach {
            $0.backgroundColor = UIColor.white.withAlphaComponent(0.8)
            $0.textColor = UIColor.black
        }

        routeUILabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8.0).isActive = true
        routeUILabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8.0).isActive = true
        view.addHorizontalSpacing(8.0, items: [routeUILabel, routeUISwitch, routePointsLabel,
                                               routePointsSwitch])
        view.addEquality(of: .centerY, items: [routeUILabel, routeUISwitch, routePointsLabel,
                                               routePointsSwitch])
        setDestinationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8.0).isActive = true
        setDestinationButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8.0).isActive = true
        setDestinationButton.widthAnchor.constraint(equalToConstant: 100.0).isActive = true
        setDestinationButton.heightAnchor.constraint(equalToConstant: 75.0).isActive = true


        engine = ARKitCoreLocationEngineImpl(
            view: sceneView,
            locationManager: NativeLocationManager.sharedInstance,
            locationEstimatesHolder: AdvancedLocationEstimatesHolder()
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate


    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }

    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        guard let routeFinishNode = routeFinishNode else { return }
        guard let parent = routeFinishNode.parent else { return }
        guard let pointOfView = renderer.pointOfView else { return }

        let bounds = UIScreen.main.bounds

        let positionInWorld = routeFinishNode.worldPosition
        let positionInPOV = parent.convertPosition(routeFinishNode.position, to: pointOfView)
        let projection = sceneView.projectPoint(positionInWorld)
        let projectionPoint = CGPoint(x: CGFloat(projection.x), y: CGFloat(projection.y))

        let screenMidToProjectionLine = CGLine(point1: bounds.mid, point2: projectionPoint)
        let intersection = screenMidToProjectionLine.intersection(withRect: bounds)

        let povWorldPosition: Vector3 = Vector3(pointOfView.worldPosition)
        let routeFinishWorldPosition: Vector3 = Vector3(positionInWorld)
        let distanceToFinishNode = (povWorldPosition - routeFinishWorldPosition).length

        DispatchQueue.main.async { [weak self] in
            guard let slf = self else { return }
            guard let routeFinishNode = slf.routeFinishNode else { return }
            guard let routeFinishHint = slf.routeFinishHint else { return }
            let placemarkSize = slf.finishPlacemarkSize(
                forDistance: CGFloat(distanceToFinishNode),
                closeDistance: 10.0,
                farDistance: 25.0,
                minSize: 50.0,
                maxSize: 100.0
            )

            let distance = floor(distanceToFinishNode)
            let targetPoint = SCNVector3(projection.x - Float(placemarkSize / 2), projection.y, projection.z)
            let unprojectedTP = slf.sceneView.unprojectPoint(targetPoint)


            let radius = (Vector3(routeFinishNode.worldPosition) - Vector3(unprojectedTP)).length
            routeFinishNode.distance = distance
            routeFinishNode.radius = CGFloat(radius)

            print("Radius: \(radius)")

            let point: CGPoint = intersection ?? projectionPoint
            let isInFront = positionInPOV.z < 0
            let isProjectionInScreenBounds: Bool = intersection == nil

            if slf.routeUISwitch.isOn {
                routeFinishHint.isHidden = (isInFront && intersection == nil)
            } else {
                routeFinishHint.isHidden = true
            }

            if isInFront {
                routeFinishHint.center = point
            } else {
                if isProjectionInScreenBounds {
                    routeFinishHint.center = CGPoint(
                        x: reflect(point.x, of: bounds.mid.x),
                        y: bounds.height
                    )
                } else {
                    routeFinishHint.center = CGPoint(
                        x: reflect(point.x, of: bounds.mid.x),
                        y: reflect(point.y, of: bounds.mid.y)
                    )
                }
            }
        }
    }

    var engine: ARKitCoreLocationEngine!

    var setDestinationButton: UIButton = UIButton(type: .system)
    var routePointsLabel: UILabel = UILabel()
    var routeUILabel: UILabel = UILabel()
    var routePointsSwitch: UISwitch = UISwitch()
    var routeUISwitch: UISwitch = UISwitch()

    var polylineNodes: [SCNNode] = [] {
        didSet {
            oldValue.forEach { $0.removeFromParentNode() }
            polylineNodes.forEach {
                sceneView.scene.rootNode.addChildNode($0)
                $0.isHidden = !routeUISwitch.isOn
            }
        }
    }

    var routePointNodes: [SCNNode] = [] {
        didSet {
            oldValue.forEach { $0.removeFromParentNode() }
            routePointNodes.forEach {
                sceneView.scene.rootNode.addChildNode($0)
                $0.isHidden = !routePointsSwitch.isOn
            }
        }
    }

    var routeFinishNode: RouteFinishNode? = nil {
        didSet {
            oldValue?.removeFromParentNode()
            if let node = routeFinishNode {
                sceneView.scene.rootNode.addChildNode(node)
                node.isHidden = !routeUISwitch.isOn
            }
        }
    }

    var routeFinishHint: UIView? = nil {
        didSet {
            oldValue?.removeFromSuperview()
            if let hintView = routeFinishHint {
                view.addSubview(hintView)
                hintView.isHidden = !routeUISwitch.isOn
            }
        }
    }
}

extension ViewController: MapViewControllerDelegate {
    func viewController(_ mapVc: MapViewController, didSetDestination destination: CLLocationCoordinate2D) {
        self.update(withDestination: destination)
    }
}

fileprivate extension ViewController {

    func makeFinishNodeHint() -> UIView {
        let hintView = UIView()
        hintView.frame = CGRect(x: 0.0, y: 0.0, width: 50, height: 50)
        hintView.layer.cornerRadius = 25.0
        hintView.backgroundColor = UIColor.red
        return hintView
    }

    /// RouteFinishPlacemark size driven by design requirements
    ///
    /// - Parameters:
    ///   - distance: distance to route finish
    func finishPlacemarkSize(forDistance distance: CGFloat, closeDistance: CGFloat, farDistance: CGFloat,
                             minSize: CGFloat, maxSize: CGFloat) -> CGFloat
    {
        guard closeDistance >= 0 else { assert(false); return 0.0 }
        guard closeDistance >= 0, farDistance >= 0, closeDistance <= farDistance else { assert(false); return 0.0 }

        if distance > farDistance {
            return minSize
        } else if distance < closeDistance{
            return maxSize
        } else {
            let delta = maxSize - minSize
            let percent: CGFloat = ((distance - closeDistance) / (farDistance - closeDistance))
            let size = minSize + delta * percent
            return size
        }
    }

    func createSphereNode(withRadius radius: CGFloat, color: UIColor) -> SCNNode {
        let geometry = SCNSphere(radius: radius)
        geometry.firstMaterial?.diffuse.contents = color
        let sphereNode = SCNNode(geometry: geometry)
        return sphereNode
    }

    func findProjection(ofNode node: SCNNode, inSceneOfView scnView: SCNView) -> CGPoint {
        let nodeWorldPosition = node.worldPosition
        let projection = scnView.projectPoint(nodeWorldPosition)
        return CGPoint(x: CGFloat(projection.x), y: CGFloat(projection.y))
    }

    func isNodeInFrontOfCamera(_ node: SCNNode, scnView: SCNView) -> Bool {
        guard let pointOfView = scnView.pointOfView else { return false }
        guard let parent = node.parent else { return false }
        let positionInPOV = parent.convertPosition(node.position, to: pointOfView)
        return positionInPOV.z < 0
    }
}
