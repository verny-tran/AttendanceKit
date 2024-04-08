//
//  LecturerController.swift
//  Institution
//
//  Created by Dũng/Verny/서비스개발팀 on 16/03/2024.
//

import UIKit
import AVFoundation
import General

final class LecturerController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var doneButton: UIButton!
    
    var lecturerName: String?
    var lecturerID: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        FaceNet.main.load()
        
        self.dismissKeyboardInteractively()
        self.doneButton.corner(radius: 16)
        
        self.nameTextField.text = self.lecturerName
        self.idTextField.text = self.lecturerID
    }
    
    @IBAction func buttonDone(_ sender: Any) {
        guard let name = self.nameTextField.text, !name.isBlank
        else { self.showDialog(message: "Please fill lecturer name!"); return }

        guard let id = self.idTextField.text, !id.isBlank
        else { self.showDialog(message: "Please fill lecturer ID!"); return }
        
        guard let password = self.passwordTextField.text, !password.isBlank
        else { self.showDialog(message: "Please fill password!"); return }
        
        self.showLoading()
        print("Lecturer name is: \(name)")
        
        Firebase.manager.uploadLecturer((id, name)) { [weak self] in
            guard let `self` = self else { return }
            
            self.hideLoading()
            self.showDialog("Lecturer account created successfully.", completion: { [weak self] in
                guard let `self` = self else { return }
                self.navigationController?.popViewController(animated: true)
            })
        }
        
        Firebase.manager.uploadPassword((id, password)) { [weak self] in
            guard let `self` = self else { return }
            
            self.hideLoading()
            self.showDialog("Lecturer account created successfully.", completion: { [weak self] in
                guard let `self` = self else { return }
                self.navigationController?.popViewController(animated: true)
            })
        }
    }
}

