//
//  RecordVideoViewController.swift
//  PersonRez
//
//  Created by Trần T. Dũng  on 31/07/2022.
//

import UIKit
import AVFoundation
import MBProgressHUD
import SwiftUI

struct RecordVideoViewControllerRepresentation: UIViewControllerRepresentable {
    typealias UIViewControllerType = RecordVideoViewController
    
    func makeUIViewController(context: Context) -> RecordVideoViewController {
        UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RecordVideoViewController") as! RecordVideoViewController
    }
    
    func updateUIViewController(_ uiViewController: RecordVideoViewController, context: Context) {
        
    }
}

class RecordVideoViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    @IBOutlet weak var desLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var videoView: VideoView!
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var movieOutput = AVCaptureMovieFileOutput()
    
    var timeRecord = 5
    var timer = Timer()
    
    var outputVideoUrl: URL?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)
        else {
            print("Unable to access front camera!")
            return
        }
        do {
            let input = try AVCaptureDeviceInput(device: frontCamera)
            stillImageOutput = AVCapturePhotoOutput()
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                setupLivePreview()
            }
        }
        catch let error  {
            print("Error Unable to initialize front camera:  \(error.localizedDescription)")
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openFillName" {
            let vc = segue.destination as! AddNameViewController
            vc.videoURL = outputVideoUrl
        }
    }
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        guard AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front) != nil else {
            showDialog(message: "Not supported in simulator!")
            return
        }
        if startButton.titleLabel?.text == "Start" {
            desLabel.text = "Move your head slowly!"
            startButton.isEnabled = false
            captureSession.addOutput(movieOutput)
            let paths = documentDirectory.appendingPathComponent("output.mov")
            try? FileManager.default.removeItem(at: paths)
            movieOutput.startRecording(to: paths, recordingDelegate: self)
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        }
        else {
            self.captureSession.stopRunning()
            self.performSegue(withIdentifier: "openFillName", sender: nil)
        }
        
    }
    
    @objc func timerAction() {
        timeRecord -= 1
        startButton.setTitle("\(timeRecord) seconds remaining!", for: .disabled)
        if timeRecord == 0 {
            self.movieOutput.stopRecording()
            timer.invalidate()
            startButton.isEnabled = true
            timeRecord = 5
            startButton.setTitle("Done", for: .normal)
        }
    }
    
    func setupLivePreview() {
        videoView.layer.cornerRadius = 150
        videoView.layer.masksToBounds = true
        videoView.layer.borderWidth = 10
        videoView.layer.borderColor = UIColor.green.cgColor
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = videoView.layer.bounds
        
        videoPreviewLayer.connection?.videoOrientation = .portrait
        videoView.layer.insertSublayer(videoPreviewLayer, at: 0)
        DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
            self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.videoView.bounds
            }
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print("FINISHED RECORD VIDEO")
        if error == nil {
            outputVideoUrl = outputFileURL
        }
    }
}
