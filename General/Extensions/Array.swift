//
//  Array.swift
//  Student
//
//  Created by Dũng/Verny/서비스개발팀 on 21/12/2023.
//

import Foundation

extension Array {
    public var shuffle: [Element] {
        var elements = self
        
        for index in 0 ..< elements.count {
            let anotherIndex = Int(arc4random_uniform(UInt32(elements.count - index))) + index
            anotherIndex != index ? elements.swapAt(index, anotherIndex) : ()
        }
        
        return elements
    }
    
    public mutating func shuffled() {
        self = self.shuffle
    }
}
