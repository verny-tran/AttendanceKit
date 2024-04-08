//
//  RecordVideoViewController.swift
//  PersonRez
//
//  Created by Trần T. Dũng  on 31/07/2022.
//

import UIKit
import AVFoundation
import General

class SampleController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    @IBOutlet weak var guideLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var videoView: UIView!
    
    private let circularProgressView = CircularProgressView()
    
    var captureSession = AVCaptureSession()
    var movieFileOutput = AVCaptureMovieFileOutput()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var timer = Timer()
    var videoDuration: TimeInterval = 5
    
    var outputFileURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.startButton.corner(radius: 16)
        self.captureSession.sessionPreset = .high
        
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)
        else { print("Unable to access front camera!"); return }
        
        do { 
            let deviceInput = try AVCaptureDeviceInput(device: frontCamera)
            let photoOutput = AVCapturePhotoOutput()
            
            guard self.captureSession.canAddInput(deviceInput) &&
                  self.captureSession.canAddOutput(photoOutput) else { return }
            
            self.captureSession.addInput(deviceInput)
            self.captureSession.addOutput(photoOutput)
            
            self.setupVideoPreviewLayer()
            
        } catch let error  {
            print("Error Unable to initialize front camera:  \(error.localizedDescription)")
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "openFillName" else { return }

        let studentController = segue.destination as? StudentController
        studentController?.videoURL = self.outputFileURL
    }
    
    @IBAction func buttonStart(_ sender: UIButton) {
        guard AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front) != nil 
        else { self.showDialog(message: "Not supported in simulator!"); return }
        
        if self.startButton.titleLabel?.text == "Start" {
            self.guideLabel.text = "Move your head slowly!"
            self.startButton.isEnabled = false
            self.captureSession.addOutput(self.movieFileOutput)
            
            let paths = Directory.applicationDocuments.appendingPathComponent("output.mov")
            try? FileManager.default.removeItem(at: paths)
            
            self.movieFileOutput.startRecording(to: paths, recordingDelegate: self)
            self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(count), userInfo: nil, repeats: true)
            
        } else {
            self.captureSession.stopRunning()
            self.performSegue(withIdentifier: "openFillName", sender: nil)
        }
    }
    
    @objc 
    func count() {
        self.videoDuration -= 0.1
        self.startButton.setTitle("\(Int(self.videoDuration)) seconds remaining!", for: .disabled)
        self.circularProgressView.progress = (5 - self.videoDuration) / 5
        
        guard self.videoDuration <= 0 else { return }
        self.movieFileOutput.stopRecording()
        
        self.timer.invalidate()
        self.videoDuration = 5
        
        self.startButton.isEnabled = true
        self.startButton.setTitle("Done", for: .normal)
    }
    
    func setupVideoPreviewLayer() {
        self.circularProgressView.ringWidth = 10
        self.circularProgressView.color = .green
        self.circularProgressView.frame = self.videoView.layer.bounds
        
        self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.videoPreviewLayer?.frame = self.videoView.layer.bounds
        self.videoPreviewLayer?.videoGravity = .resizeAspectFill
        self.videoPreviewLayer?.connection?.videoOrientation = .portrait
        
        guard let previewLayer = self.videoPreviewLayer else { return }
        self.videoView.stroke(radius: 150, size: 2, color: .lightGray)
        self.videoView.addSubview(self.circularProgressView)
        self.videoView.layer.masksToBounds = true
        self.videoView.layer.insertSublayer(previewLayer, at: 0)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let `self` = self else { return }
            self.captureSession.startRunning()
            
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.videoPreviewLayer?.frame = self.videoView.bounds
            }
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error == nil { self.outputFileURL = outputFileURL }
        
        print("FINISHED RECORD VIDEO")
    }
}
