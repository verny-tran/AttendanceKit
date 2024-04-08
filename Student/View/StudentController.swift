//
//  MainController.swift
//  Student
//
//  Created by Dũng/Verny/서비스개발팀 on 02/01/2024.
//

import UIKit
import AVFoundation
import RealmSwift
import General


class StudentController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var stackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageView.stroke(radius: 25.5, size: 1, color: .opaqueSeparator)
        self.stackView.arrangedSubviews.forEach({ $0.corner(radius: 16) })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        FaceNet.main.clean()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
        FaceNet.main.load()
    }
}

