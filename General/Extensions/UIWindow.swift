//
//  UIWindow.swift
//  General
//
//  Created by Dũng/Verny/서비스개발팀 on 12/03/2024.
//

import UIKit

extension UIWindow {
    static var keyWindow: UIWindow? {
        /// A `key window of main app exists`, go ahead and use it
        if let window = UIApplication.shared.keyWindow, window.windowLevel == .normal { return window }
        
        /// Otherwise, `try to find a normal level window`
        let window = UIApplication.shared.windows.first { $0.windowLevel == .normal }
        
        guard let result = window else {  return nil }
        return result
    }
}
