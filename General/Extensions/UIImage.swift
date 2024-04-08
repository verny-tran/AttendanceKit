//
//  UIImage+Resize.swift
//  PersonRez
//
//  Created by Trần T. Dũng  on 31/07/2022.
//

import Foundation
import UIKit

extension UIImage {
    public func resized(to smallestSide: Int) -> UIImage? {
        let smallestSide = CGFloat(smallestSide)
        let newSize: CGSize
        if size.width > size.height {
            newSize = CGSize(width: size.width / size.height * smallestSide, height: smallestSide)
        } else {
            newSize = CGSize(width: smallestSide, height: size.height / size.width * smallestSide)
        }
        
        UIGraphicsBeginImageContextWithOptions(newSize, true, 1)
        draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    public func resized(to size: CGSize) -> UIImage? {
        let widthRatio  = size.width  / self.size.width
        let heightRatio = size.height / self.size.height
        
        let newSize = widthRatio > heightRatio ?  CGSize(width: self.size.width * heightRatio, height: self.size.height * heightRatio)
                                                : CGSize(width: self.size.width * widthRatio,  height: self.size.height * widthRatio)
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        
        self.draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
    
    public func resized(to dimension: (width: CGFloat, height: CGFloat)) -> UIImage? {
        let size = CGSize(width: floor(dimension.width), height: floor(dimension.height))
        let rect = CGRect(x: 0, y: 0, width: dimension.width, height: dimension.height)
        
        UIGraphicsBeginImageContext(size)
        
        self.draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
}

extension UIImage {
    public func rotated(by angle: Float) -> UIImage? {
        let angle = CGFloat(angle)
        
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: angle)).size
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        
        let context = UIGraphicsGetCurrentContext()!
    
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        context.rotate(by: angle)
        
        let rect = CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height)
        self.draw(in: rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
    
    public func changeBrightness(value: Int) -> UIImage? {
        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(Float(value) / 100, forKey: kCIInputBrightnessKey)
        let rawimgData = CIImage(image: self)
        filter?.setValue(rawimgData, forKey: "inputImage")
        let outpuImage = filter?.value(forKey: "outputImage")
        return UIImage(ciImage: outpuImage as! CIImage)
    }
    
    public func changeConstrast(value: Int) -> UIImage? {
        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(Float(value) / 100, forKey: kCIInputContrastKey)
        let rawimgData = CIImage(image: self)
        filter?.setValue(rawimgData, forKey: "inputImage")
        let outpuImage = filter?.value(forKey: "outputImage")
        return UIImage(ciImage: outpuImage as! CIImage)
    }
    
    public func createImageList() -> [UIImage?] {
        var list: [UIImage] = []
        list.append(changeBrightness(value: 20)!)
        list.append(changeBrightness(value: -5)!)
        //list.append(rotate(radians: .pi / 8)!)
        //list.append(rotate(radians: -(.pi / 8))!)
        list.append(self)
        return list
    }
}

extension UIImage {
    public func horizontallyFlipped() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, true, self.scale)
        
        let context = UIGraphicsGetCurrentContext()!
        
        context.translateBy(x: self.size.width/2, y: self.size.height/2)
        context.scaleBy(x: -1.0, y: 1.0)
        context.translateBy(x: -self.size.width/2, y: -self.size.height/2)
        
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
}


