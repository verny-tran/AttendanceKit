//
//  Student.swift
//  General
//
//  Created by Dũng/Verny/서비스개발팀 on 21/12/2023.
//

import UIKit

public struct Student {
    public var name: String
    public var image: UIImage
    public var time: String
    
    /// Copy of <detectedUsers>, use it to `ignore appended users`
    public static var all: [Student] = []
    
    public init(name: String, image: UIImage, time: String) {
        self.name = name
        self.image = image
        self.time = time
    }
}
