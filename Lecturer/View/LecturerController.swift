//
//  LecturerController.swift
//  Lecturer
//
//  Created by Dũng/Verny/서비스개발팀 on 02/01/2024.
//

import General
import UIKit
import AVFoundation
import RealmSwift


class LecturerController: UIViewController {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var lecturerLabel: UILabel!
    
    private var lecturerID: String? { UserDefaults.standard.value(forKey: "lecturerID") as? String }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.stackView.arrangedSubviews.forEach({ $0.corner(radius: 16) })
        self.lecturerLabel.text = self.lecturerID
        
        guard !Reachability.isConnectedToInternet else { return }
        self.showDialog(message: "You have not connected to internet. Using local data.")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
    
    @IBAction func buttonIntervene(_ sender: Any) {
        self.showDialog(message: "Undeveloped feature")
    }
}

