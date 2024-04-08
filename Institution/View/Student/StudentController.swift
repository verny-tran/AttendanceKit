//
//  StudentNameController.swift
//  Institution
//
//  Created by Trần T. Dũng  on 31/07/2022.
//

import UIKit
import AVFoundation
import General

class StudentController: UIViewController {
    @IBOutlet weak var faceImageView: UIImageView!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var doneButton: UIButton!
    
    private var generator: AVAssetImageGenerator!
    
    var studentName: String?
    var studentID: String?
    
    var videoURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        FaceNet.main.load()
        
        self.dismissKeyboardInteractively()
        self.doneButton.corner(radius: 16)
        
        self.nameTextField.text = self.studentName
        self.idTextField.text = self.studentID

        guard let videoURL = self.videoURL else { return }
        self.thumbnailImage(from: videoURL, completion: { thumbnail in
            self.faceImageView.image = thumbnail
            self.faceImageView.corner(radius: self.faceImageView.frame.height / 2)
        })
    }
    
    @IBAction func buttonDone(_ sender: Any) {
        guard let name = self.nameTextField.text, !name.isBlank
        else { self.showDialog(message: "Please fill student name!"); return }

        guard let id = self.idTextField.text, !id.isBlank
        else { self.showDialog(message: "Please fill student ID!"); return }
        
        guard let password = self.passwordTextField.text, !password.isBlank
        else { self.showDialog(message: "Please fill password!"); return }
        
        self.showLoading()
        
        /// Save to `local data`.
        UserDefaults.savedUsers.append(id)
        UserDefaults.standard.set(UserDefaults.savedUsers, forKey: Constant.savedUsers)
        
        guard let videoURL = self.videoURL
        else { return self.uploadStudent((id, name, password)) }
        
        self.uploadStudent((id, name, password))
        self.uploadVectors(of: (id, name))
    }
    
    private func uploadStudent(_ student: (id: String, name: String, password: String)) {
        Firebase.manager.uploadStudent((student.id, student.name)) { [weak self] in
            guard let `self` = self else { return }
            
            self.hideLoading()
            self.showDialog("Student \(student.id) uploaded.", completion: { [weak self] in
                guard let `self` = self else { return }
                self.navigationController?.popToRootViewController(animated: true)
            })
        }
        
        Firebase.manager.uploadPassword((student.id, student.password)) { [weak self] in
            guard let `self` = self else { return }
            
            self.hideLoading()
            self.showDialog("Student \(student.id) uploaded.", completion: { [weak self] in
                guard let `self` = self else { return }
                self.navigationController?.popToRootViewController(animated: true)
            })
        }
    }
    
    private func uploadVectors(of student: (id: String, name: String)) {
        guard let videoURL = self.videoURL else { return }
        self.showLoading()
        
        Frame.getAllFrames(from: videoURL, for: student.id) { allVectors, kMeansVectors in
            Firebase.manager.uploadKMeanVectors(kMeansVectors) { [weak self] in
                guard let `self` = self else { return }
                
                self.hideLoading()
                self.showDialog("Upload \(kMeansVectors.count) K Means vectors for \(student.name).", completion: { [weak self] in
                    guard let `self` = self else { return }
                    self.navigationController?.popToRootViewController(animated: true)
                })
            }
            
            Firebase.manager.uploadAllVectors(allVectors) { [weak self] in
                guard let `self` = self else { return }
                
                self.hideLoading()
                self.showDialog("Upload \(allVectors.count) vectors for \(student.name).", completion: { [weak self] in
                    guard let `self` = self else { return }
                    self.navigationController?.popToRootViewController(animated: true)
                })
            }
        }
    }
    
    private func thumbnailImage(from videoURL: URL, completion: @escaping ((UIImage?) -> Void)) {
        DispatchQueue.global().async {
            let asset = AVAsset(url: videoURL)
            
            let assetImageGenerator = AVAssetImageGenerator(asset: asset)
            assetImageGenerator.appliesPreferredTrackTransform = true
            
            let thumbnailTimeInterval = CMTimeMake(value: 2, timescale: 1)
            
            do {
                let cgImage = try assetImageGenerator.copyCGImage(at: thumbnailTimeInterval, actualTime: nil)
                let thumbnail = UIImage(cgImage: cgImage)
                
                DispatchQueue.main.async { completion(thumbnail) }
            } catch { print(error.localizedDescription)
                
                DispatchQueue.main.async { completion(nil) }
            }
        }
    }
}
