//
//  FaceNet.swift
//  Student
//
//  Created by Dũng/Verny/서비스개발팀 on 21/12/2023.
//

import Foundation
import UIKit

public final class FaceNet {
    public static let main = FaceNet()
    
    public typealias Output = [CIImage]
    
    private var wrapper: tfWrap?
    private let model: String = "facenet.pb"
    
    private let detector = CIDetector(ofType: CIDetectorTypeFace, context: nil,
                                      options: [CIDetectorAccuracy: CIDetectorAccuracyLow])
    
    public var isModelLoaded: Bool { self.wrapper != nil }
    
    public func load() {
        self.clean()
        
        self.wrapper = tfWrap()
        self.wrapper?.loadModel(self.model, labels: nil, memMapped: false,optEnv: true)
        self.wrapper?.setInputLayer("input", outputLayer: "embeddings")
    }
    
    public func clean() {
        self.wrapper?.clean()
        self.wrapper = nil
    }
    
    public func run(on frame: CIImage) -> [Double] {
        let edge: Int = 160
        
        let resizedImage = frame.resized(to: (CGFloat(edge), CGFloat(edge)))
        
        guard let wrapper = self.wrapper, let cgImage = resizedImage?.cgImage else { return [] }
        
        let width = edge
        let height = edge
        let allocator = kCFAllocatorDefault
        let pixelFormatType = kCVPixelFormatType_32BGRA
        let pixelBufferAttributes = [String(kCVPixelBufferIOSurfacePropertiesKey): [:]] as CFDictionary
        
        var buffer: CVPixelBuffer?
        
        CVPixelBufferCreate(
            allocator, width, height,
            pixelFormatType, pixelBufferAttributes,
            &buffer
        )
        
        let input = CIImage(cgImage: cgImage)
        if let buffer = buffer { CIContext().render(input, to: buffer) }
        
        guard let networkOutput = wrapper.run(onFrame: buffer) else { return [] }
        let output = networkOutput.compactMap { ($0 as? NSNumber)?.doubleValue }
        
        return output
    }
    
    public func extractFaces(from frame: CIImage) -> Output {
        guard let features = self.detector?.features(in: frame, options: [CIDetectorSmile: true]) as? [CIFaceFeature]
        else { return [] }
        
        return features.map({ (feature) -> CIImage in
            let rect = feature.bounds
            let cropped = frame.cropped(to: rect)
            let face = cropped.transformed(by: CGAffineTransform(translationX: -rect.origin.x, y: -rect.origin.y))
            
            return face
        })
    }
}

