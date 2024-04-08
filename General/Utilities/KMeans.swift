//
//  KMeansClustering.swift
//  Student
//
//  Created by Dũng/Verny/서비스개발팀 on 21/12/2023.
//

import Foundation
import Accelerate
import Darwin

public class KMeans {
    public static let clustering = KMeans()
    
    public typealias Vector = [Double]
    public typealias Centroids = Array<Vector>
    public typealias Clusters = Array<[Vector]>
    
    public enum Error {
        case noVectors
        case noDimension
        case noClusteringNumber
        case clusteringNumberLargerThanVectorsNumber
        
        case otherReason(String)
    }
    
    /// `Dimension` of every vector
    public var dimension: Int = 128
    
    /// `Clustering number` <K>
    public var clusteringNumberOfK: Int = 2
    
    /// `Max interation`
    public var maxIteration: Int = 100
    
    /// `Convergence` Error
    public var convergenceError = 0.01
    
    /// `Number` of `excution`
    public var numberOfExcution = 1
    
    /// `Vectors`
    public var vectors = Array<Vector>()
    
    /// Final `centroids`
    public var finalCentroids = Centroids()
    
    /// Final `clusters`
    public var finalClusters = Clusters()
    
    /// `Temporary` centroids
    fileprivate var centroids = Centroids()
    
    /// `Temporary` clusters
    fileprivate var clusters = Clusters()
    
    private var cost: Double { var cost = 0.0
        for index in 0 ..< self.clusteringNumberOfK { for vector in self.clusters[index] {
            cost += self.squaredEuclideanDistance(from: vector, to: self.centroids[index])
        } }
        
        return cost
    }
    
    public func add(_ vector: Vector) {
        self.vectors.append(vector)
    }
    
    public func add(_ vectors: [Vector]) {
        for vector in vectors { self.add(vector) }
    }
    
    public func reset() {
        self.vectors.removeAll()
        self.centroids.removeAll()
        self.clusters.removeAll()
        
        self.finalCentroids.removeAll()
        self.finalClusters.removeAll()
    }
    
    private func randomlyPickInitialCentroids() {
        let indexes = self.vectors.count.randomIndex[0 ..< self.clusteringNumberOfK]
        var initialCentroids = Centroids()
        
        for index in indexes { initialCentroids.append(vectors[index]) }
        
        self.centroids = initialCentroids
    }
    
    private func recalculateCentroids() -> Double {
        var moveDistance = 0.0
        
        for index in 0 ..< self.clusteringNumberOfK {
            var newCentroid = Vector(repeating: 0, count: self.dimension)
            let vectorSum = self.clusters[index].reduce(newCentroid, { $0.add($1) })
            
            var s = Double(self.clusters[index].count)
            
            vDSP_vsdivD(vectorSum, 1, &s, &newCentroid, 1, vDSP_Length(vectorSum.count))
            
            let squaredDistance = self.squaredEuclideanDistance(from: self.centroids[index], to: newCentroid)
            if moveDistance < squaredDistance { moveDistance = squaredDistance }
            
            self.centroids[index] = newCentroid
        }
        
        return moveDistance
    }
    
    public func clustering(_ numberOfExcutions:Int, completion: (_ success: Bool, _ centroids: Centroids, _ clusters: Clusters) -> Void) {
        self.beginClustering(with: numberOfExcutions)
        
        return completion(true, self.finalCentroids, self.finalClusters)
    }
    
    private func beginClustering() -> Double {
        self.randomlyPickInitialCentroids()
        
        var iteration = 0
        var moveDistance = 1.0
        
        while iteration < self.maxIteration && moveDistance > self.convergenceError { iteration += 1
            self.assignVectorsToCluster()
            
            moveDistance = self.recalculateCentroids()
        }
        
        return self.cost
    }
    
    private func beginClustering(with numberOfExcution: Int) {
        var numberOfExcution = numberOfExcution
        if numberOfExcution < 1 { return }
        
        var cost = -1.0
        while numberOfExcution > 0 {
            let newCost = self.beginClustering()
            
            if cost == -1.0 || cost > newCost { cost = newCost
                self.finalCentroids = self.centroids
                self.finalClusters = self.clusters
            }
            
            numberOfExcution -= 1
        }
    }
    
    private func assignVectorsToCluster() {
        self.clusters.removeAll()
        for _ in 0 ..< self.clusteringNumberOfK { self.clusters.append([]) }
        
        for vector in self.vectors {
            var groupNumber = 0
            var temporaryDistance = -1.0
            
            for index in 0 ..< self.clusteringNumberOfK {
                let squaredDistance = self.squaredEuclideanDistance(from: vector, to: self.centroids[index])
                
                if temporaryDistance == -1.0 {
                    temporaryDistance = squaredDistance
                    groupNumber = index
                    
                    continue
                }
                
                if squaredDistance < temporaryDistance { groupNumber = index }
            }
            
            self.clusters[groupNumber].append(vector)
        }
    }
}

extension KMeans {
    private func euclideanDistance(from v1: Vector, to v2: Vector) -> Double {
        let distance = self.squaredEuclideanDistance(from: v1, to: v2)
        return sqrt(distance)
    }
    
    private func squaredEuclideanDistance(from v1: Vector, to v2: Vector) -> Double {
        var subVector = [Double](repeating: 0.0, count: v1.count)
        vDSP_vsubD(v1, 1, v2, 1, &subVector, 1, vDSP_Length(v1.count))
        
        var distance = 0.0
        vDSP_dotprD(subVector, 1, subVector, 1, &distance, vDSP_Length(subVector.count))
        
        return abs(distance)
    }
}

extension KMeans.Vector {
    public func asString() -> String {
        var string = ""
        for item in self { string += ",\(item)" }
        
        return string
    }
    
    public func add(_ vector: KMeans.Vector) -> KMeans.Vector {
        var addresult = KMeans.Vector(repeating: 0.0, count: self.count)
        vDSP_vaddD(self, 1, vector, 1, &addresult, 1, vDSP_Length(self.count))
        
        return addresult
    }
}
