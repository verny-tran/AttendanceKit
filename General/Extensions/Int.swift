//
//  Int.swift
//  Student
//
//  Created by Dũng/Verny/서비스개발팀 on 21/12/2023.
//

import Foundation

extension Int {
    public var random: Int { Int(arc4random_uniform(UInt32(abs(self)))) }
    
    public var randomIndex: [Int] { Array(0 ..< self).shuffle }
}

extension Int {
    public func doubleDigit() -> String {
        return self > 9 ? "\(self)" : "0\(self)"
    }
}
