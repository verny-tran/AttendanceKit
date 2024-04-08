//
//  String.swift
//  Student
//
//  Created by Dũng/Verny/서비스개발팀 on 21/12/2023.
//

import Foundation

extension String {
    public var isBlank: Bool { !Regex.blank.validate(self) }
}

extension String {
    public func asVector() -> KMeans.Vector {
        var array = self.components(separatedBy: ",")
        array.removeFirst()
        
        var vector = [Double]()
        for item in array {
            guard let scalar = Double(item) else { return [] }
            vector.append(scalar)
        }
        
        return vector
    }
}
