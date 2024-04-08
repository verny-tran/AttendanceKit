//
//  LoginController.swift
//  Student
//
//  Created by Dũng/Verny/서비스개발팀 on 14/03/2024.
//

import General
import RealmSwift

final class LoginController: UIViewController {
    @IBOutlet weak var classLabel: UILabel!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    var classID: String?
    var className: String?
    
    private var classes = [String : [String : Any]]()
    private var passwords = [String : String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dismissKeyboardInteractively()
        self.classLabel.text = nil
        
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
        
        self.login(username)
    }
    
    private func login(_ username: String) {
        UserDefaults.standard.set(username, forKey: "studentID")
        
        let isAccessible = UserDefaults.standard.value(forKey: "isAccessible") as? Bool
        
        guard let isAccessible = isAccessible, isAccessible
        else { return self.showDialog("Please scan a class-embedded NFC tag.", completion: { [weak self] in
            guard let `self` = self else { return }
            self.navigationController?.popToRootViewController(animated: true)
        }) }
        
        self.showLoading()
        
        Firebase.manager.loadClasses(student: username) { [weak self] classes in
            guard let `self` = self else { return }
            self.hideLoading()
            
            self.classes = classes
            self.validate { [weak self] in
                guard let `self` = self else { return }
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(identifier: "RecognizeController")
                
                guard let recognizeController = viewController as? RecognizeController else { return }
                recognizeController.onDetected = { [weak self] viewController, identifier in
                    guard let `self` = self else { return }
                    
                    viewController.dismiss(animated: true, completion: { [weak self] in
                        guard let `self` = self else { return }
                        self.navigationController?.popToRootViewController(animated: true)
                        
                        guard identifier == username
                        else { return self.showDialog("Student facial biometrics mismatched!") }
                        
                        let viewController = storyboard.instantiateViewController(identifier: "CountingController")
                        
                        guard let countingController = viewController as? CountingController else { return }
                        countingController.studentID = username
                        countingController.classID = self.classID
                        countingController.className = self.className
                        
                        self.navigationController?.pushViewController(countingController, animated: true)
                    })
                }
                
                self.present(recognizeController, animated: true)
            }
        }
    }
    
    private func validate(completion: @escaping () -> Void) {
        guard let room = UserDefaults.standard.value(forKey: "room") as? String,
              let classID = self.classes.first(where: { $0.value["room"] as? String == room })?.key
        else { return self.showDialog("This room is not in your class schedule.", completion: { [weak self] in
            guard let `self` = self else { return }
            self.navigationController?.popToRootViewController(animated: true)
        }) }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy, HH:mm"
        
        guard let time = self.classes[classID]?["date"] as? String, let date = dateFormatter.date(from: time),
              let duration = self.classes[classID]?["duration"] as? TimeInterval,
              let className = self.classes[classID]?["name"] as? String else { return }
        
        self.classID = classID
        self.className = className
        
        guard Date.now > date else { return self.showDialog("Class has not started yet!", completion: { [weak self] in
            guard let `self` = self else { return }
            self.navigationController?.popToRootViewController(animated: true)
        }) }
        
        let deadline = date + duration * 60
        guard Date.now < deadline else { return self.showDialog("You are late!", completion: { [weak self] in
            guard let `self` = self else { return }
            self.navigationController?.popToRootViewController(animated: true)
        }) }
        
        self.classLabel.text = "\(classID) starting at \(time)\nDuration \(duration) minutes."
        
        completion()
    }
    
    private func load() {
        guard Reachability.isConnectedToInternet else { return self.loadLocal() }
        self.showLoading()
        
        Firebase.manager.loadKMeansVectors { kMeanVectors in
            Vector.kMeanVectors = kMeanVectors
            Vector.kMeanVectors.forEach { Vector.save($0) }
            
            /// Save `local data`
            try? Realm.main.write { Realm.main.deleteAll() }
            self.hideLoading()
        }
        
        Firebase.manager.loadPasswords { [weak self] passwords in
            guard let `self` = self else { return }
            self.passwords = passwords
            
            self.hideLoading()
        }
    }
    
    private func loadLocal() {
        Vector.kMeanVectors = Realm.main.objects(SavedVector.self).map({ vector in
            Vector(name: vector.name, vector: vector.vector.asVector(), distance: vector.distance)
        })
    }
}
