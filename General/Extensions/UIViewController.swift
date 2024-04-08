//
//  UIViewController.swift
//  General
//
//  Created by Trần T. Dũng  on 31/07/2022.
//

import UIKit

extension UIViewController {
    public static var topMost: UIViewController? {
        let keyWindow = UIWindow.keyWindow
        if let window = keyWindow, !window.isKeyWindow { window.makeKey() }
        
        guard var topViewController = keyWindow?.rootViewController else { return nil }
        while let currentTop = topViewController.presentedViewController {
            topViewController = currentTop
        }
        
        return topViewController
    }
}

extension UIViewController {
    public func showLoading() {
        DispatchQueue.main.async {
            let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
            
            let visualEffectView = UIVisualEffectView(effect: blurEffect)
            visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            visualEffectView.frame = self.view.bounds
            visualEffectView.alpha = 0
            self.view.addSubview(visualEffectView)
            
            let activityIndicatorView = UIActivityIndicatorView(style: .large)
            self.view.addSubview(activityIndicatorView)
            
            activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
            activityIndicatorView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            activityIndicatorView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
            
            activityIndicatorView.startAnimating()
            
            visualEffectView.fadeIn()
        }
    }
    
    public func hideLoading() {
        DispatchQueue.main.async {
            for case let visualEffectView as UIVisualEffectView in self.view.subviews {
                visualEffectView.fadeOut(completion: { [weak visualEffectView] in
                    visualEffectView?.removeFromSuperview()
                    
                    for case let activityIndicatorView as UIActivityIndicatorView in self.view.subviews {
                        activityIndicatorView.stopAnimating()
                        activityIndicatorView.removeFromSuperview()
                    }
                })
            }
        }
    }
}

extension UIViewController {
    public func showDialog(_ message: String, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion?()
        }))
        
        self.present(alertController, animated: true)
    }
    
    public func showDialog(title: String? = nil, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        self.present(alertController, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            alertController.dismiss(animated: true)
        }
    }
}

extension UIViewController {
    public func dismissKeyboardInteractively() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
}
