//
//  ViewController.swift
//  Collisions
//
//  Created by Livia Vasconcelos on 06/01/20.
//  Copyright © 2020 Livia Vasconcelos. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    
    let configuration = ARWorldTrackingConfiguration()
    var power: Float = 50
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.debugOptions = [SCNDebugOptions.showWorldOrigin, SCNDebugOptions.showFeaturePoints]
        sceneView.session.run(configuration)
        sceneView.automaticallyUpdatesLighting = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneView.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView else { return }
        guard let pointOfView = sceneView.pointOfView else { return }
        
        let transform   = pointOfView.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location    = SCNVector3(transform.m41, transform.m42, transform.m43)
        let position    = orientation + location
        
        let bullet = SCNNode(geometry: SCNSphere(radius: 0.1))
        bullet.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        bullet.position = position
        
        let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: bullet))
        body.isAffectedByGravity = false
        bullet.physicsBody = body
        bullet.physicsBody?.applyForce(SCNVector3(orientation.x * power,
                                                  orientation.y * power,
                                                  orientation.z * power), asImpulse: true)
        
        self.sceneView.scene.rootNode.addChildNode(bullet)
    }

    @IBAction func addTargets(_ sender: Any) {
        self.addEgg(x: 5, y: 0, z: -40)
        self.addEgg(x: 0, y: 0, z: -40)
        self.addEgg(x: -5, y: 0, z: -40)
    }
    
    func addEgg(x: Float, y: Float, z: Float) {
        let eggScene = SCNScene(named: "Egg.scnassets/egg.scn")
        let eggNode  = eggScene?.rootNode.childNode(withName: "egg", recursively: false)
        
        eggNode?.position = SCNVector3(x, y, z)
        
        
        if let egg = eggNode {
            eggNode?.physicsBody = SCNPhysicsBody(type: .static,
                                                  shape: SCNPhysicsShape(node: egg,
                                                                         options: nil))
            self.sceneView.scene.rootNode.addChildNode(egg)
        }
        
    }
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}
