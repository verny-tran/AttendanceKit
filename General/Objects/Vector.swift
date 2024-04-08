//
//  Vector.swift
//  General
//
//  Created by Dũng/Verny/서비스개발팀 on 21/12/2023.
//

import Foundation
import RealmSwift

public class SavedVector: Object {
    @objc public dynamic var name: String = ""
    @objc public dynamic var vector: String = ""
    @objc public dynamic var distance: Double = 0
}

public struct Vector: Hashable, Equatable {
    public var name: String
    public var vector: [Double]
    public var distance: Double
    
    public static var kMeanVectors = [Vector]()
    
    public static func == (lhs: Vector, rhs: Vector) -> Bool {
        return lhs.vector == rhs.vector
    }
    
    public init(name: String, vector: [Double], distance: Double) {
        self.name = name
        self.vector = vector
        self.distance = distance
    }
}

extension Vector {
    public static func load() -> [Vector] {
        Realm.main.objects(SavedVector.self).map({
            Vector(name: $0.name, vector: $0.vector.asVector(), distance: $0.distance)
        })
    }
    
    public static func save(_ vector: Vector) {
        let savedVector = SavedVector()
        savedVector.name = vector.name
        savedVector.vector = vector.vector.asString()
        savedVector.distance = vector.distance
        
        try? Realm.main.write { Realm.main.add(savedVector) }
    }
    
    public static func add(_ name: String, completion: @escaping ([Vector]) -> Void) {
        let images = Frame.ImageDataset.training.images(of: name)
        print(images.count)
        
        guard images.count > 0 else { completion([]); return }
        
        let vectors: [Vector] = images.compactMap({ self.vector(name, $0) })
        
        completion(vectors)
    }
    
    public static func vector(_ name: String, _ image: UIImage) -> Vector? {
        guard let frame = CIImage(image: image) else { return nil }
        let faces = FaceNet.main.extractFaces(from: frame)
        
        guard let face = faces.first else { return nil }
        let vector = FaceNet.main.run(on: face)
        
        guard vector.count == 128 else { return nil }
        return (Vector(name: name, vector: vector, distance: 0))
    }
    
    public static func vector(from image: UIImage) -> Vector {
        var array = [Vector]()
        var result = Vector(name: "Unknown", vector: [], distance: 10)
        
        let image = image
        let frame = CIImage(image: image)!
        
        let faces = FaceNet.main.extractFaces(from: frame)
        
        if let face = faces.first { let targetVector = FaceNet.main.run(on: face)
            
            for vector in Vector.kMeanVectors {
                let distance = self.l2distance(from: targetVector, to: vector.vector)
                
                if distance * 1000 < 700 { array.append(vector)
                    
                    if distance < result.distance {
                        result = vector
                        result.distance = distance
                    }
                }
            }
            
            if result.distance * 1000 < 400  {
                result.distance = 100
                return result
            }
            
            let groupedItems = Dictionary(grouping: array, by: {$0.name})
            var count = 0
            var max = 0
            
            for item in groupedItems {
                if item.value.count > max { max = item.value.count; count = 1 }
                else if item.value.count == max { count += 1 }
            }
            
            switch max {
            case 1: result.distance = 70
            case 2: result.distance = 90
            case 0: result.distance = 0
            default: result.distance = 100
            }
            
            return result
        }
        
        result.distance = 100
        
        return result
    }

    public static func kMeanVectors(from vectors: [Vector]) -> [Vector] {
        var kMeanVectors = [Vector]()
        let groupedItems = Dictionary(grouping: vectors, by: { $0.name })
        
        print(groupedItems.count)
        
        for item in groupedItems {
            self.kMeansVectors(thatHasSameNameWith: item.value) { kMeansVector in
                kMeanVectors.append(contentsOf: kMeansVector)
            }
        }
        
        return kMeanVectors
    }
    
    public static func kMeansVectors(thatHasSameNameWith vectors: [Vector], completion: @escaping ([Vector]) -> Void) {
        KMeans.clustering.reset()
        
        for index in 0 ..< vectors.count { KMeans.clustering.add(vectors[index].vector) }
        
        KMeans.clustering.clusteringNumberOfK = Constant.clusteringNumberOfK
        KMeans.clustering.clustering(500) { success, centroids, clusters in
            guard success else { return }
            
            let name = vectors.first?.name ?? ""
            let vectors = centroids.compactMap({ Vector(name: name, vector: $0, distance: 0) })
            
            completion(vectors)
        }
    }
    
    public static func l2distance(from feat1: [Double], to feat2: [Double]) -> Double {
        return sqrt(zip(feat1, feat2).map { f1, f2 in pow(f2 - f1, 2) }.reduce(0, +))
    }
}
