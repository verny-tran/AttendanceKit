//
//  Frame.swift
//  General
//
//  Created by Trần T. Dũng  on 31/07/2022.
//

import UIKit
import AVKit
import CoreML

public final class Frame {
    public static let fps: Int = 2
    
    public static func getAllFrames(from videoURL: URL, for identifier: String, completion: @escaping ([Vector], [Vector]) -> Void) {
        let asset: AVAsset = AVAsset(url: videoURL)
        let duration: Double = CMTimeGetSeconds(asset.duration)
        
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImageGenerator.appliesPreferredTrackTransform = true
        
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 10
        
        var iteration: Double = 0
        
        repeat {
            let imageOperation = Frame.ImageOperation(time: iteration, label: identifier, assetImageGenerator: assetImageGenerator)
            operationQueue.addOperation(imageOperation)
            
            iteration = iteration + (1 / Double(self.fps))
        } while (iteration < duration)
        
        operationQueue.addBarrierBlock {
            
            Vector.add(identifier) { allVectors in
                print("All vectors for \(identifier): \(allVectors.count)")
                
                guard allVectors.count > 0 else { UIViewController.topMost?.hideLoading(); return }

                Vector.kMeansVectors(thatHasSameNameWith: allVectors) { kMeansVectors in
                    print("K-mean vectors for \(identifier): \(kMeansVectors.count)")
                    
                    completion(allVectors, kMeansVectors)
                }
            }
        }
    }
}

extension Frame {
    public class ImageOperation: Operation {
        private var assetImageGenerator: AVAssetImageGenerator
        
        public var time: TimeInterval
        public var label: String
        
        public init(time: Double, label: String, assetImageGenerator: AVAssetImageGenerator) {
            self.time = time
            self.label = label
            self.assetImageGenerator = assetImageGenerator
        }
        
        public override func main() {
            self.getFrame(at: self.time, for: self.label)
        }
        
        private func getFrame(at time: TimeInterval, for label: String) {
            let time = CMTime(seconds: time, preferredTimescale: 60)
            let image: UIImage
            
            guard let cgImage = try? self.assetImageGenerator.copyCGImage(at: time, actualTime: nil) else { return }
            image = UIImage(cgImage: cgImage)
            
            ImageDataset.training.save(image, for: label)
            
            if let image = image.rotated(by: .pi / 20) { ImageDataset.training.save(image, for: label) }
            if let image = image.rotated(by: -.pi / 20) { ImageDataset.training.save(image, for: label) }
            if let image = image.horizontallyFlipped() { ImageDataset.training.save(image, for: label) }
        }
    }
}

extension Frame {
    public class ImageDataset {
        public static let training = ImageDataset(purpose: .train)
        public static let testing = ImageDataset(purpose: .test)
        
        public let purpose: Purpose
        public enum Purpose: String {
            case train
            case test
            
            var folder: String { self.rawValue }
        }
        
        public let smallestSide = 500
        private let url: URL
        
        public init(purpose: Purpose) {
            self.purpose = purpose
            self.url = Directory.applicationDocuments.appendingPathComponent(purpose.folder)
            
            Directory.createDirectory(at: self.url)
        }
        
        public func save(_ image: UIImage, for label: String) {
            let folder = Directory.applicationDocuments.appendingPathComponent(self.purpose.folder)
                                                       .appendingPathComponent(label)
            Directory.createDirectory(at: folder)
            
            let fileName = UUID().uuidString + ".jpg"
            let fileURL = folder.appendingPathComponent(fileName)
            
            guard !FileManager.default.fileExists(atPath: fileURL.path),
                  let image = image.resized(to: self.smallestSide),
                  let data = image.jpegData(compressionQuality:  1.0) else { return }

            do { try data.write(to: fileURL); print("Saved at \(fileURL)") }
            catch { print("Error saving file:", error) }
        }
        
        public func images(of label: String) -> [UIImage] {
            var urls = [URL]()
            var images = [UIImage]()
            
            let folder = Directory.applicationDocuments.appendingPathComponent(self.purpose.folder)
                                                       .appendingPathComponent(label)
            
            guard let contents = Directory.contentsOfDirectory(at: folder, matching: { url in
                url.pathExtension == "jpg" || url.pathExtension == "png"
            }) else { return [] }
            
            urls.append(contentsOf: contents)
            
            for index in 0 ..< urls.count {
                if let image = UIImage(contentsOfFile: urls[index].path) { images.append(image) }
            }
            
            return images
        }
    }

}
