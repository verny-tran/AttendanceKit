//
//  WriteController.swift
//  Institution
//
//  Created by Dũng/Verny/서비스개발팀 on 10/03/2024.
//

import General
import UIKit
import CoreNFC

final class ClassController: UIViewController {
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var roomTextField: UITextField!
    @IBOutlet weak var durationTextField: UITextField!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var doneButton: UIButton!
    
    var classID: String?
    var className: String?
    var room: String?
    var duration: TimeInterval?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dismissKeyboardInteractively()
        self.doneButton.corner(radius: 16)
        
        self.idTextField.text = self.classID
        self.nameTextField.text = self.className
        self.roomTextField.text = self.room
        self.durationTextField.text = self.duration?.description
    }
    
    @IBAction func buttonWrite(_ sender: Any) {
        guard let id = self.idTextField.text, !id.isBlank,
              let name = self.nameTextField.text, !name.isBlank,
              let room = self.roomTextField.text, !room.isBlank,
              let duration = self.durationTextField.text, !duration.isBlank, let duration = TimeInterval(duration)
        else { self.showDialog(message: "Missing class information."); return }

        self.showLoading()
        Firebase.manager.uploadClass((id, name, room, self.datePicker.date, duration), completion: { [weak self] in
            guard let `self` = self else { return }
            
            self.hideLoading()
            self.showDialog("Class \(id) added.", completion: { [weak self] in
                guard let `self` = self else { return }
                self.navigationController?.popViewController(animated: true)
            })
        })
    }
}
