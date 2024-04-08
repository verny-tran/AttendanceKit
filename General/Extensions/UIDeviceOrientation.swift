//
//  UIDeviceExtension.swift
//  General
//
//  Created by Trần T. Dũng  on 31/07/2022.
//

import Foundation
import AVKit

extension UIDeviceOrientation {
    public var videoOrientation: AVCaptureVideoOrientation? {
        switch self {
        case .portrait: return .portrait
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeLeft: return .landscapeRight
        case .landscapeRight: return .landscapeLeft
        default: return nil
        }
    }
}

