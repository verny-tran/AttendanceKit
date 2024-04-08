//
//  PreviewView.swift
//  PersonRez
//
//  Created by Trần T. Dũng  on 31/07/2022.
//

import UIKit
import Vision
import AVFoundation

class PreviewView: UIView {
    private var maskLayer = [CAShapeLayer]()
    private var textLayer = [CATextLayer]()
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    weak var session: AVCaptureSession? {
        get {
            videoPreviewLayer?.videoGravity = .resizeAspectFill
            return videoPreviewLayer?.session
        }
        
        set {
            videoPreviewLayer = layer as? AVCaptureVideoPreviewLayer
            videoPreviewLayer?.videoGravity = .resizeAspectFill
            videoPreviewLayer?.session = newValue
        }
    }
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    // Create a new layer drawing the bounding box
    private func createLayer(in rect: CGRect, prediction: String) -> CAShapeLayer{
        let mask = CAShapeLayer()
        mask.frame = rect
        mask.cornerRadius = 10
        mask.opacity = 1
        mask.borderWidth = 2.0
        mask.borderColor = #colorLiteral(red: 0, green: 0.595081985, blue: 0.9414320588, alpha: 1).cgColor
        
        let label = CATextLayer()
        label.frame = rect
        label.string = prediction
        label.fontSize = 20
        layer.addSublayer(label)
        
        textLayer.append(label)
        maskLayer.append(mask)
        layer.insertSublayer(mask, at: 1)
        
        return mask
    }
    
    
    func drawFaceboundingBox(face : VNFaceObservation, label: String) {
        
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -frame.height)
        let translate = CGAffineTransform.identity.scaledBy(x: frame.width, y: frame.height)
        let facebounds = face.boundingBox.applying(translate).applying(transform)
        _ = createLayer(in: facebounds, prediction: label)
    }
    func ImageInRect(_ rect: CGRect) -> UIImage? {
        return nil
    }
    func removeMask() {
        for mask in maskLayer {
            mask.removeFromSuperlayer()
        }
        for text in textLayer {
            text.removeFromSuperlayer()
        }
        textLayer.removeAll()
        maskLayer.removeAll()
    }
    
    func speak(name: String) {
        let utterance = AVSpeechUtterance(string: "Hello \(name)")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
    
    
    func showDiaglog3s(name: String,_ success: Bool) {
        let title = success == false ?  "Can't join!" : "Joining..."
        let alert = UIAlertController(title: title, message: "\(name)", preferredStyle: .alert)
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        let when = DispatchTime.now() + 1
        
        DispatchQueue.main.asyncAfter(deadline: when) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
    

}





