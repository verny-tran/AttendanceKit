//
//  RecognizeController.swift
//  Student
//
//  Created by Trần T. Dũng  on 31/07/2022.
//

import UIKit
import Vision
import AVFoundation
import FaceCropper
import General

class RecognizeController: UIViewController {
    @IBOutlet weak var previewView: PreviewView!
    @IBOutlet weak var captureButton: UIButton!
    
    private var setupResult: SessionSetupResult = .success
    private enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    
    private var session: AVCaptureSession!
    private var isSessionRunning = false
    private let sessionQueue = DispatchQueue(label: "session queue", attributes: [], target: nil)
    
    private var currentFrame: UIImage?
    private var devicePosition: AVCaptureDevice.Position = .front
    
    private var videoDeviceInput: AVCaptureDeviceInput!
    private var videoDataOutput: AVCaptureVideoDataOutput!
    private var videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue")
    
    private var requests = [VNRequest]()
    
    var onDetected: ((UIViewController, String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        self.captureButton.corner(radius: 16)
        
        FaceNet.main.load()
        
        print("Number of kMeans: \(Vector.kMeanVectors.count)")
        self.session = AVCaptureSession()
        self.previewView.session = session
        
        /// Set up `Vision Request`
        self.setupVision()
        
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video){
        case .authorized:
            break
            
        case .notDetermined:
            self.sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { [unowned self] granted in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
            })
            
        default: self.setupResult = .notAuthorized
        }
        
        self.sessionQueue.async { () -> Void in
            self.configureSession()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.sessionQueue.async {() -> Void in
            switch self.setupResult {
            case .success:
                self.addObservers()
                self.session.startRunning()
                self.isSessionRunning = self.session.isRunning
                
            case .notAuthorized:
                DispatchQueue.main.async { [unowned self] in
                    let message = NSLocalizedString("AVCamBarcode doesn't have permission to use the camera, please change privacy settings", comment: "Alert message when the user has denied access to the camera")
                    let    alertController = UIAlertController(title: "AppleFaceDetection", message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"), style: .`default`, handler: { action in
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                    }))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
                
            case .configurationFailed:
                DispatchQueue.main.async { [unowned self] in
                    let message = NSLocalizedString("Unable to capture media", comment: "Alert message when something goes wrong during capture session configuration")
                    let alertController = UIAlertController(title: "AppleFaceDetection", message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        FaceNet.main.clean()
        
        super.viewDidDisappear(animated)
        
        self.sessionQueue.async { [weak self] ()  -> Void in
            guard let `self` = self, self.setupResult == .success else { return }

            self.isSessionRunning = self.session.isRunning
            self.removeObservers()
            self.stopCaptureSession()
        }
    }
    
    fileprivate func stopCaptureSession() {
        self.session.stopRunning()
        self.requests.forEach({ $0.cancel() })
        self.requests = []
        
        self.session = nil
        self.videoDeviceInput = nil
        self.videoDataOutput = nil
    }
    
    @IBAction func buttonPhoto(_ sender: Any) {
        guard let frame = self.currentFrame else { return }
        let today = Date()
        
        DateFormatter.main.dateFormat = Constant.dateFormat
        let timestamp = DateFormatter.main.string(from: today)
        
        let user = Student(name: Constant.takePhotoName, image: frame, time: timestamp)
        self.showDialog(message: Constant.takePhotoName)
    }
    
    @IBAction func buttonCamera(_ sender: Any) {
        guard let currentCameraInput: AVCaptureInput = self.session.inputs.first else { return }
        self.session.beginConfiguration()
        self.session.removeInput(currentCameraInput)

        self.devicePosition = self.devicePosition == .back ? .front : .back
        self.addVideoDataInput()
        self.session.commitConfiguration()
    }
}

extension RecognizeController {
    private func configureSession() {
        if self.setupResult != .success { return }
        
        self.session.beginConfiguration()
        self.session.sessionPreset = .hd1920x1080
        
        self.addVideoDataInput()
        self.addVideoDataOutput()
        
        self.session.commitConfiguration()
    }
    
    private func addVideoDataInput() {
        do {
            var defaultVideoDevice: AVCaptureDevice!
            
            if self.devicePosition == .front {
                if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front) {
                    defaultVideoDevice = frontCameraDevice
                }
            } else {
                if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: AVMediaType.video, position: .back) {
                    defaultVideoDevice = dualCameraDevice
                }
                
                else if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) {
                    defaultVideoDevice = backCameraDevice
                }
            }
            
            guard let videoDevice = defaultVideoDevice
            else { self.showDialog("Simulator is unsupported!"); return }
            
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            if self.session.canAddInput(videoDeviceInput) {
                self.session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                
                DispatchQueue.main.async {
                    guard let statusBarOrientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation else { return }
                    var initialVideoOrientation: AVCaptureVideoOrientation = .portrait
                    
                    if statusBarOrientation != .unknown, let videoOrientation = statusBarOrientation.videoOrientation {
                        initialVideoOrientation = videoOrientation
                    }
                    
                    self.previewView.videoPreviewLayer?.connection?.videoOrientation = initialVideoOrientation
                }
            }
            
        } catch { print("Could not add video device input to the session")
            
            self.setupResult = .configurationFailed
            self.session.commitConfiguration()
            
            return
        }
    }
    
    private func addVideoDataOutput() {
        self.videoDataOutput = AVCaptureVideoDataOutput()
        self.videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String): Int(kCVPixelFormatType_32BGRA)]
        
        
        if self.session.canAddOutput(self.videoDataOutput) {
            self.videoDataOutput.alwaysDiscardsLateVideoFrames = true
            self.videoDataOutput.setSampleBufferDelegate(self, queue: self.videoDataOutputQueue)
            self.session.addOutput(self.videoDataOutput)
            
        } else { print("Could not add metadata output to the session")
            
            self.setupResult = .configurationFailed
            self.session.commitConfiguration()
            
            return
        }
    }
}

extension RecognizeController {
    private func addObservers() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(sessionRuntimeError),
            name: Notification.Name("AVCaptureSessionRuntimeErrorNotification"),
            object: self.session
        )
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(sessionWasInterrupted),
            name: Notification.Name("AVCaptureSessionWasInterruptedNotification"),
            object: self.session
        )
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(sessionInterruptionEnded),
            name: Notification.Name("AVCaptureSessionInterruptionEndedNotification"),
            object: self.session
        )
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc 
    func sessionRuntimeError(_ notification: Notification) {
        guard let errorValue = notification.userInfo?[AVCaptureSessionErrorKey] as? NSError else { return }
        
        let error = AVError(_nsError: errorValue)
        print("Capture session runtime error: \(error)")
        
        guard error.code == .mediaServicesWereReset else { return }
        
        self.sessionQueue.async { [unowned self] in
            if self.isSessionRunning {
                self.session.startRunning()
                self.isSessionRunning = self.session.isRunning
            }
        }
    }
    
    @objc
    func sessionWasInterrupted(_ notification: Notification) {
        guard let userInfoValue = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject?,
            let reasonIntegerValue = userInfoValue.integerValue,
              let reason = AVCaptureSession.InterruptionReason(rawValue: reasonIntegerValue) else { return }
            
        print("Capture session was interrupted with reason \(reason)")
    }
    
    @objc
    func sessionInterruptionEnded(_ notification: Notification) {
        print("Capture session interruption ended")
    }
}

extension RecognizeController {
    func setupVision() {
        let faceDetectionRequest = VNDetectFaceRectanglesRequest(completionHandler: self.handleFaces)
        self.requests = [faceDetectionRequest]
    }
    
    func handleFaces(request: VNRequest, error: Error?) {
        DispatchQueue.main.async {[weak self]() -> Void in
            guard let `self` = self else { return }
            
            /// Perform `all UI updates` on the `main queue`
            guard let results = request.results as? [VNFaceObservation] else { return }
            self.previewView.removeMask()
            
            let label = self.getLabel(image: self.currentFrame)
            results.forEach { face in
                self.previewView.drawFaceboundingBox(face: face, label: label)
            }
        }
    }
    
    func getLabel(image: UIImage?) -> String {
        var label = Constant.unknown
        
        guard let frame = image else { return Constant.unknown }
        let result = Vector.vector(from: frame)
        
        label = "\(result.name): \(result.distance)%"
        
        if result.name != Constant.unknown {
            let  label = result.name
            let today = Date()
            
            DateFormatter.main.dateFormat = Constant.dateFormat
            let timestamp = DateFormatter.main.string(from: today)
            
            if label != Constant.currentLabel {
                Constant.currentLabel = label
                Constant.numberOfFramesDeteced = 1
            } else {
                Constant.numberOfFramesDeteced += 1
            }
            
            let detectedStudent = Student(name: label, image: frame, time: timestamp)
            
            if Constant.numberOfFramesDeteced > Constant.validFrames { print("Detected")
                self.onDetected?(self, result.name)
                self.onDetected = nil
                
                if Student.all.count == 0 { print("Append 1")
                    self.speak(name: label)
                    
                    Frame.ImageDataset.training.save(detectedStudent.image, for: detectedStudent.name)
                    Student.all.append(detectedStudent)
                    
                    self.showDialog(message: "Recognized!")
                    
                } else  {
                    var count = 0
                    for item in Student.all {
                        
                        if item.name == label {
                            if let time = DateFormatter.main.date(from: item.time) {
                                let difference = abs(time.timeOfDayInterval(toDate: today))
                                print("Different: \(difference) seconds")
                                
                                if Int(difference) > Constant.validTime {
                                    Student.all.append(detectedStudent)
                                    Student.all = Student.all.sorted(by: { $0.time > $1.time })
                                    
                                    Frame.ImageDataset.training.save(detectedStudent.image, for: detectedStudent.name)
                                    
                                    self.speak(name: label)
                                    self.showDialog(message: "Recognized!")
                                }
                            }
                            
                            break
                            
                        } else { count += 1 }
                    }
                    
                    if count == Student.all.count {
                        Frame.ImageDataset.training.save(detectedStudent.image, for: detectedStudent.name)
                        
                        Student.all.append(detectedStudent)
                        Student.all = Student.all.sorted(by: { $0.time > $1.time })
                        
                        self.speak(name: label)
                        self.showDialog(message: "Recognized!")
                    }
                }
            }
        }
        
        return label
    }
    
    func speak(name: String) {
        let utterance = AVSpeechUtterance(string: "Hello \(name)")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
}

extension RecognizeController {
    func exifOrientation(from deviceOrientation: AVCaptureDevice.Position) -> UInt32 {
        enum DeviceOrientation: UInt32 {
            case top0ColLeft = 1
            case top0ColRight = 2
            case bottom0ColRight = 3
            case bottom0ColLeft = 4
            case left0ColTop = 5
            case right0ColTop = 6
            case right0ColBottom = 7
            case left0ColBottom = 8
        }
        
        var exifOrientation: DeviceOrientation
        
        switch UIDevice.current.orientation {
        case .portraitUpsideDown:
            exifOrientation = .left0ColBottom
            
        case .landscapeLeft:
            exifOrientation = deviceOrientation == .front ? .bottom0ColRight : .top0ColLeft
            
        case .landscapeRight:
            exifOrientation = deviceOrientation == .front ? .top0ColLeft : .bottom0ColRight
            
        default:
            exifOrientation = deviceOrientation == .front ? .left0ColTop : .right0ColTop
        }
        
        return exifOrientation.rawValue
    }
}

extension RecognizeController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func cameraWithPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: AVMediaType.video, position: .unspecified
        )
        
        return discoverySession.devices.first(where: { $0.position == position })
    }
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let exifOrientation = self.exifOrientation(from: self.devicePosition)
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
              let exifOrientation = CGImagePropertyOrientation(rawValue: exifOrientation) else { return }
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return  }
        
        let image = UIImage(cgImage: cgImage)
        self.currentFrame = image.rotated(by: .pi/2)
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: exifOrientation, options: [:])
        
        do { try imageRequestHandler.perform(requests) }
        catch { print(error) }
    }
}
