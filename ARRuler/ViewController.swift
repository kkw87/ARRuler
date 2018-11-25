//
//  ViewController.swift
//  ARRuler
//
//  Created by Kevin Wang on 11/23/18.
//  Copyright © 2018 Kevin Wang. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet var sceneView: ARSCNView!
    
    // MARK: - Instance Variables
    private var dotNodes = [SCNNode]() {
        didSet {
            if dotNodes.count >= 2 {
                calculateDistance(fromNodes: dotNodes)
            }
            
            if dotNodes.isEmpty {
                currentTextNode = nil
            }
        }
    }
    
    private var currentTextNode : SCNNode? {
        willSet {
            currentTextNode?.removeFromParentNode()
        }
        didSet {
            if currentTextNode != nil {
                sceneView.scene.rootNode.addChildNode(currentTextNode!)
            }
        }
    }
    
    // MARK: - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [.showFeaturePoints]
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
    
    // MARK: - Gesture methods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touchLocation = touches.first?.location(in: sceneView) else {
            return
        }
        
        if let hitTestResult = sceneView.hitTest(touchLocation, types: .featurePoint).first {
            
            if dotNodes.count == 2 {
                
                for node in dotNodes {
                    node.removeFromParentNode()
                }
                
                dotNodes = []
            } else {
                let newDot = createDot(at: hitTestResult)
                dotNodes.append(newDot)
                sceneView.scene.rootNode.addChildNode(newDot)
            }
            
        }
        
        
    }
    
    // MARK: - Node creation methods
    
    private func createDot(at location: ARHitTestResult) -> SCNNode {
        
        let ball = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        ball.materials = [material]
        
        let ballNode = SCNNode(geometry: ball)
        ballNode.position = SCNVector3(location.worldTransform.columns.3.x, location.worldTransform.columns.3.y, location.worldTransform.columns.3.z)
        
        return ballNode
    }
    
    private func createText(at input : String, atLocation location : SCNVector3) {
        
        let textGeomtry = SCNText(string: input, extrusionDepth: 1.0)
        let textColorMaterial = SCNMaterial()
        textColorMaterial.diffuse.contents = UIColor.red
        
        textGeomtry.materials = [textColorMaterial]
        
        let textNode = SCNNode(geometry: textGeomtry)
        textNode.position = SCNVector3(location.x, location.y + 0.01, location.z)
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        
        currentTextNode = textNode
    }
    
    // MARK: - Calculate functions
    private func calculateDistance(fromNodes : [SCNNode]) {
        let start = fromNodes[0]
        let end = fromNodes[1]
        
        //Distance between 2 three dimensions
        // √(a∧2 + b∧2 + c∧2)
        let a = (end.position.x - start.position.x)
        let b = (end.position.y - start.position.y)
        let c = (end.position.z - start.position.z)
        
        let distance = sqrt(
            pow(a, 2) +
                pow(b, 2) +
                pow(c, 2)
        )
        
        let distanceInInches = (distance * 100) * 0.39
        
        createText(at: String(abs(distanceInInches)), atLocation: end.position)
        
    }
    
    // MARK: - ARSCNViewDelegate
    
    //    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    //
    //        guard let planeAnchor = anchor as? ARPlaneAnchor else {
    //            return
    //        }
    //
    //        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
    //
    //        let planeNode = SCNNode(geometry: plane)
    //        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
    //        planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
    //
    //        sceneView.scene.rootNode.addChildNode(planeNode)
    //
    //    }
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
}
