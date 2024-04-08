//
//  LoginController.swift
//  Lecturer
//
//  Created by Dũng/Verny/서비스개발팀 on 17/03/2024.
//

import General
import RealmSwift

final class LoginController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    private var passwords = [String : String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dismissKeyboardInteractively()
        
        self.imageView.stroke(radius: 25.5, size: 1, color: .opaqueSeparator)
        self.loginButton.corner(radius: 16)
        
        guard Reachability.isConnectedToInternet
        else { return self.showDialog("You have not connected to internet. Using local data.") }
        
        self.load()
    }
    
    @IBAction func buttonLogin(_ sender: Any) {
        guard let username = self.usernameTextField.text, !username.isBlank,
              let password = self.passwordTextField.text, !password.isBlank
        else { self.showDialog("Empty student ID or password."); return }
        
        guard self.passwords[username] == password
        else { self.showDialog("Incorrect password."); return }
        
        UserDefaults.standard.set(username, forKey: "lecturerID")
        
        self.performSegue(withIdentifier: "LecturerController", sender: nil)
    }
    
    private func load() {
        guard Reachability.isConnectedToInternet else { return }
        self.showLoading()
        
        Firebase.manager.loadPasswords { [weak self] passwords in
            guard let `self` = self else { return }
            self.passwords = passwords
            
            self.hideLoading()
        }
    }
}
