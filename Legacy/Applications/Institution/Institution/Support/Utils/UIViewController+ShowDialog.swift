//
//  UIViewController+ShowDialog.swift
//  PersonRecognize
//
//  Created by Trần T. Dũng  on 31/07/2022.
//

import UIKit

extension UIViewController {
    func showDialog(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func showDiaglog3s(name: String,_ success: Bool) {
        let title = success == false ?  "Can't join!" : "Joining..."
        let alert = UIAlertController(title: title, message: "\(name)", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        let when = DispatchTime.now() + 1
        
        DispatchQueue.main.asyncAfter(deadline: when) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
}

