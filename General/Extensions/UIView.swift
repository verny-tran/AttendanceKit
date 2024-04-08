//
//  UIView.swift
//  Student
//
//  Created by Dũng/Verny/서비스개발팀 on 03/03/2024.
//

import UIKit

extension UIView {
    public func corner(radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.cornerCurve = .continuous
        self.layer.borderWidth = 0
        self.layer.borderColor = UIColor.clear.resolvedColor(with: .current).cgColor
    }
    
    public func stroke(radius: CGFloat, size: CGFloat, color: UIColor) {
        self.clipsToBounds = true
        
        self.layer.cornerRadius = radius
        self.layer.cornerCurve = .continuous
        self.layer.borderWidth = size
        self.layer.borderColor = color.resolvedColor(with: .current).cgColor
    }
}

extension UIView {
    func fadeIn(alpha: CGFloat = 1, duration: TimeInterval = 0.2, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration, animations: { self.alpha = alpha },
                       completion: { [weak self] _ in
            guard let `self` = self else { return }
            if alpha != 0 { self.isHidden = false }
            
            completion?()
        })
    }
    
    func fadeOut(alpha: CGFloat = 0, duration: TimeInterval = 0.2, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration, animations: { self.alpha = alpha },
                       completion: { [weak self] _ in
            guard let `self` = self else { return }
            if alpha == 0 { self.isHidden = true }
            
            completion?()
        })
    }
    
    func fadeTransition(_ duration: CFTimeInterval = 0.2) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.type = .fade
        animation.duration = duration
        
        self.layer.add(animation, forKey: CATransitionType.fade.rawValue)
    }
}
