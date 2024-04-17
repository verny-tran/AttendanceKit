//
//  ViewController.swift
//  Student
//
//  Created by Trần T. Dũng  on 05/08/2022.
//

import SwiftUI
import UIKit
import AVKit
import Vision
import ARKit
import CoreML
import SceneKit
import FirebaseStorage

var code = false

class ARViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, ARSessionDelegate {
    let sceneView = ARSCNView(frame: UIScreen.main.bounds)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(sceneView)
        sceneView.delegate = self
        sceneView.showsStatistics = true
        
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        
        configuration.isLightEstimationEnabled = true
        
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
}

extension ARViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        guard let device = sceneView.device else {
            return nil
        }
        
        let faceGeometry = ARSCNFaceGeometry(device: device)
        
        let node = SCNNode(geometry: faceGeometry)
        
        node.geometry?.firstMaterial?.fillMode = .lines
        
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor,
            let faceGeometry = node.geometry as? ARSCNFaceGeometry else {
                return
        }
        
        faceGeometry.update(from: faceAnchor.geometry)
        
        let text = SCNText(string: "", extrusionDepth: 2)
        let font = UIFont(name: "SFMono-Regular", size: 20)
        text.font = font
        text.flatness = 1
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.black
        
        text.materials = [material]
        text.firstMaterial?.isDoubleSided = true
        
        let textNode = SCNNode(geometry: faceGeometry)
        textNode.position = SCNVector3(-0.1, -0.01, -0.5)
        print(textNode.position)
        
        textNode.scale = SCNVector3(0.002, 0.002, 0.002)
        textNode.geometry = text
        
        guard let model = try? VNCoreMLModel(for: CreateML(configuration: .init()).model) else {
            fatalError("Unable to load model")
        }
        
        let coreMlRequest = VNCoreMLRequest(model: model) {[weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first
                else {
                    fatalError("Unexpected results")
            }

            DispatchQueue.main.async {[weak self] in
                print(topResult.identifier)
                if topResult.identifier != "Unknown" {
                    text.string = topResult.identifier
                    self?.sceneView.scene.rootNode.addChildNode(textNode)
                    self?.sceneView.autoenablesDefaultLighting = true
                    
                    if code == false {
                        let alert = UIAlertController(title: "Attendance checking successfully!", message: "Artificial Intelligence Class Friday Morning.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                            NSLog("The \"OK\" alert occured.")
                        }))
                        self?.present(alert, animated: true, completion: nil)
                        
                        code = true
                        
                        UserDefaults.standard.set("In class...", forKey: "status")
                    }
                }
            }
        }
        
        guard let pixelBuffer = self.sceneView.session.currentFrame?.capturedImage else { return }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        DispatchQueue.global().async {
            do {
                try handler.perform([coreMlRequest])
            } catch {
                print(error)
            }
        }
    }
    
}
