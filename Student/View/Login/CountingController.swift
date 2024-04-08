//
//  CountingController.swift
//  Student
//
//  Created by Dũng/Verny/서비스개발팀 on 14/03/2024.
//

import General

final class CountingController: UIViewController {
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var studentLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var checkoutButton: UIButton!
    
    var studentID: String?
    
    var classID: String?
    var className: String?
    
    private var passwords = [String : String]()
    
    private var timer: Timer?
    private var seconds: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let studentID = self.studentID, let className = self.className else { return }
        self.studentLabel.text = "Student \(studentID)"
        self.classLabel.text = className
        
        self.checkoutButton.corner(radius: 16)
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, 
                                          selector: #selector(count),
                                          userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.checkout()
    }
    
    @IBAction func buttonCheckout(_ sender: Any) { self.checkout() }
    
    @objc
    private func count() {
        self.seconds += 1
        
        let minutes: Int = self.seconds / 60
        let seconds: Int = self.seconds % 60
        
        self.timerLabel.text = "\(minutes.doubleDigit()):\(seconds.doubleDigit())"
    }
    
    private func checkout() {
        self.timer?.invalidate()
        
        guard let studentID = self.studentID, let classID = self.classID else { return }
        let attendance = (studentID, classID, Date(), TimeInterval(self.seconds))
        
        self.showDialog(title: "Uploading attended duration", message: "Please wait...")
        
        Firebase.manager.uploadAttendance(attendance, completion: { [weak self] in
            guard let `self` = self else { return }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.navigationController?.popToRootViewController(animated: true)
            })
        })
    }
}
