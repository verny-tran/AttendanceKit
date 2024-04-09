//
//  PredictImageViewController.swift
//  PersonRez
//
//  Created by Trần T. Dũng  on 31/07/2022.
//

import UIKit
import AVFoundation
import FaceCropper
import MBProgressHUD
import ProgressHUD
//import KDTree

class PredictImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var mainImg: UIImageView!
    @IBOutlet weak var face1: UIImageView!
    @IBOutlet weak var face2: UIImageView!
    @IBOutlet weak var nameFace2: UILabel!
    @IBOutlet weak var nameFace1: UILabel!
    
    
    //let knn: KNNDTW = KNNDTW()
    var corner:CGFloat = 35
    override func viewDidLoad() {
        super.viewDidLoad()
        fnet.load()
        clearData()
        
        print(kMeanVectors.count)
    }
    
    
    @IBAction func tapTakePhoto(_ sender: UIButton) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Camera is not available.")
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.cameraFlashMode = UIImagePickerController.CameraFlashMode.off
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        clearData()
        present(imagePicker, animated: true, completion: nil)
    }
    
    func clearData() {
        face2.image = nil
        face2.image = nil
        nameFace1.text = ""
        nameFace2.text = ""
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let image = info[.editedImage] as? UIImage {
            print("this is image")
            self.mainImg.image = image
            
            let start = DispatchTime.now()
            let result = vectorHelper.getResult(image: image)
            let end = DispatchTime.now()
            let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
            let timeInterval = Double(nanoTime) / 1_000_000_000
            //
            //print(re)
            //nameFace1.text = re
            nameFace1.text = "\(result.name): \(result.distance)%"
            nameFace2.text = "Time taken: \(timeInterval)seconds."
            
            image.face.crop { [self] res in
                switch res {
                case .success(let faces):
                    self.face1.image = faces[0]
                    self.face1.layer.cornerRadius = self.corner
                    self.face2.layer.cornerRadius = self.corner
                    if faces.count == 2 {
                        self.face1.image = faces[0]
                        self.face2.image = faces[1]
                        self.nameFace1.text = "\(vectorHelper.getResult(image: faces[0]).name): \(vectorHelper.getResult(image: faces[0]).distance)%"
                        self.nameFace2.text = "\(vectorHelper.getResult(image: faces[1]).name): \(vectorHelper.getResult(image: faces[1]).distance)%"
                    }
                case .notFound:
                    self.showDialog(message: "Not found any face!")
                case .failure(let error):
                    print("Error crop face: \(error)")
                }
            }
        }
    }
}
