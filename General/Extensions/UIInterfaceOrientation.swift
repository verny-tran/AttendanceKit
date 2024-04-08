//
//  UIInterfaceOrientation.swift
//  General
//
//  Created by Dũng/Verny/서비스개발팀 on 13/03/2024.
//

import AVKit

extension UIInterfaceOrientation {
    public var videoOrientation: AVCaptureVideoOrientation? {
        switch self {
        case .portrait: return .portrait
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeLeft: return .landscapeLeft
        case .landscapeRight: return .landscapeRight
        default: return nil
        }
    }
}
