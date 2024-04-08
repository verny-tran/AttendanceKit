//
//  CIImage.swift
//  Student
//
//  Created by Dũng/Verny/서비스개발팀 on 21/12/2023.
//

import CoreImage
import UIKit

extension CIImage {
    public func resized(to dimension: (width: CGFloat, height: CGFloat)) -> UIImage? {
        return UIImage(ciImage: self).resized(to: (dimension.width, dimension.height))
    }
}
