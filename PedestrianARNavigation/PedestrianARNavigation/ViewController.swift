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

    func update() {
        guard let currentLocation = engine.userLocationEstimate()?.location else { return }
        let coord = currentLocation.coordinate
        let geoRoute: [CLLocationCoordinate2D] = [
            coord,
            CLLocationCoordinate2D(latitude: coord.latitude + 0.0001, longitude: coord.longitude - 0.00005),
            CLLocationCoordinate2D(latitude: coord.latitude + 0.00006, longitude: coord.longitude - 0.00007),
            CLLocationCoordinate2D(latitude: coord.latitude + 0.00002, longitude: coord.longitude - 0.0001),
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
    }


    @objc func onArrowsSwitchValueChanged(_ sender: UISwitch) {
        polylineNodes.forEach { $0.isHidden = !sender.isOn }
    }

    @objc func onRoutePointsSwitchValueChanged(_ sender: UISwitch) {
        routePointNodes.forEach { $0.isHidden = !sender.isOn }
    }

    @objc func refreshTapped() {
        update()
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

        let axises: SCNNode = RouteGeometryFactory.axesNode(quiverLength: 4.0, quiverThickness: 0.5)
        scene.rootNode.addChildNode(axises)

        // Buttons

        restart.setTitle("Restart", for: .normal)
        restart.addTarget(self, action: #selector(refreshTapped), for: .touchUpInside)

        arrowsLabel.text = "Arrows"
        routePointsLabel.text = "Route"

        arrowsSwitch.addTarget(self, action: #selector(onArrowsSwitchValueChanged), for: .valueChanged)
        routePointsSwitch.addTarget(self, action: #selector(onRoutePointsSwitchValueChanged), for: .valueChanged)


        let settingsViews: [UIView] = [restart, arrowsLabel, arrowsSwitch, routePointsLabel, routePointsSwitch]

        settingsViews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        [restart].forEach {
            $0.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            $0.setTitleColor(UIColor.white, for: .normal)
        }

        [arrowsLabel, routePointsLabel].forEach {
            $0.backgroundColor = UIColor.white.withAlphaComponent(0.8)
            $0.textColor = UIColor.black
        }

        arrowsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8.0).isActive = true
        arrowsLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8.0).isActive = true
        view.addHorizontalSpacing(8.0, items: [arrowsLabel, arrowsSwitch, routePointsLabel,
                                               routePointsSwitch])
        view.addEquality(of: .centerY, items: [arrowsLabel, arrowsSwitch, routePointsLabel,
                                               routePointsSwitch])
        restart.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8.0).isActive = true
        restart.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8.0).isActive = true
        restart.widthAnchor.constraint(equalToConstant: 100.0).isActive = true
        restart.heightAnchor.constraint(equalToConstant: 75.0).isActive = true


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

    var engine: ARKitCoreLocationEngine!

    var restart: UIButton = UIButton(type: .system)
    var routePointsLabel: UILabel = UILabel()
    var arrowsLabel: UILabel = UILabel()
    var routePointsSwitch: UISwitch = UISwitch()
    var arrowsSwitch: UISwitch = UISwitch()

    var polylineNodes: [SCNNode] = [] {
        didSet {
            oldValue.forEach { $0.removeFromParentNode() }
            polylineNodes.forEach {
                sceneView.scene.rootNode.addChildNode($0)
                $0.isHidden = !arrowsSwitch.isOn
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
}
