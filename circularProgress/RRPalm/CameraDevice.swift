//
//  CameraDevice.swift
//  GMI
//
//  Created by ddevoe on 1/17/19.

//

import Foundation
import AVFoundation
import UIKit

/*  This is the Normal Camera implemention which talks to control the physical camera device
 */
class CameraDevice: Device, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    //
    //MARK: - Enum section
    //
    enum CameraControllerError: Swift.Error {
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }
    
    public enum CameraPosition {
        case front
        case rear
    }
    
    //
    //MARK: Camera device specific members
    //
    var session: AVCaptureSession?
    var frontCamera: AVCaptureDevice?
    var rearCamera: AVCaptureDevice?
    
    var currentCameraPosition: CameraPosition?
    var frontCameraInput: AVCaptureDeviceInput?
    var rearCameraInput: AVCaptureDeviceInput?
    var photoOutput: AVCapturePhotoOutput?
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    var faceDetector: CIDetector?
    var context: CIContext?
    //var videoDataOutput: AVCaptureVideoDataOutput?

    var photoCaptureCompletionBlock: ((UIImage?, Error?) -> Void)?
    
    var flashMode = AVCaptureDevice.FlashMode.off
    
    var videoDataOutputQueue: DispatchQueue?
    var facelockTime: Date?

    //
    //MARK:- DeviceProtocol members
    //
    override var name: String { get { return "camera"} }
    //override var canAccess: Bool { return false } //causes the requestAccess() to be called to determine access in captureViewController.viewDidLoad()
    
    override var systemAlertID: SystemAlertDataSource { return RD_15() }

    
    override func requestAccess( completion: @escaping ClosureWithBool ) {
        
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthorizationStatus {
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { response in
                    completion( response )
            }
            
        case .authorized: completion( true )
        case .restricted, .denied: completion( false )

        default:
            completion( false )
        }
    }
    
    override func initDevice( with: UIView, params: [String : Any]?, completion: @escaping ClosureWithBool ) {
        super.initDevice( with: with, params: params, completion: completion )
        
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
            completion( false )
            return
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionWasInterrupted),
                                               name: .AVCaptureSessionWasInterrupted,
                                               object: self)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionInterruptionEnded),
                                               name: .AVCaptureSessionInterruptionEnded,
                                               object: self)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionRuntimeError),
                                               name: .AVCaptureSessionRuntimeError,
                                               object: self)
        //configure the camera now
        self.prepare {(error) in
            if let _ = error {
                completion(false)
            } else  {
                
                var result = true
                do {
                    
                    try self.switchCameras(cameraPosition: CameraPosition.front)
                    try self.displayPreview(on: with)
                    
                } catch {
                    result = false
                    log.error( "Error \(error) setting up camera" )
                }
                
                completion(result)
            }
        }
    }
    
    override func deInitDevice( completion:  @escaping ClosureWithBool ) {
        super.deInitDevice( completion: completion )
        
        NotificationCenter.default.removeObserver(self)
        
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
            completion( false )
            return
        }
        
        self.unprepare()
        
        completion( true )
    }
    
    override func startCapture( completion: @escaping  ClosureWithDeviceDatumStatus ) {
        super.startCapture( completion: completion )
        
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
            completion( .error(System.IWSError.access(.denied)),Device.status.error )
            return
        }
        
    }
    
    override func stopCapture( completion:  @escaping ClosureWithDeviceDatumStatus ) {
        //DLD: super.stopCapture( completion: completion )
        
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
            completion( .error(System.IWSError.access(.denied)),Device.status.error  )
            return
        }
        
        completion( .unknown,Device.status.done )
    }
    
    override func restart() {
        super.restart()
        
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
            return
        }
    }
    
    //
    //MARK:-
    //
    func captureImage(completion: @escaping (UIImage?, Error?) -> Void) {
        guard let captureSession = self.session, captureSession.isRunning else { completion(nil, CameraControllerError.captureSessionIsMissing); return }
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = self.flashMode
        
        self.photoOutput?.capturePhoto(with: settings, delegate: self)
        self.photoCaptureCompletionBlock = completion
    }
    
    func switchCameras( cameraPosition: CameraPosition ) throws {
        
        /* Ensures that we have a valid, running capture session before attempting to switch cameras. It also verifies that there is a camera that’s currently active.*/
        guard let currentCameraPosition = currentCameraPosition, let captureSession = self.session, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        
        // Tells the capture session to begin configuration.
        captureSession.beginConfiguration()
        
        func switchToFrontCamera() throws {
            guard let inputs = captureSession.inputs as? [AVCaptureInput], let rearCameraInput = self.rearCameraInput, inputs.contains(rearCameraInput),
                let frontCamera = self.frontCamera else { throw CameraControllerError.invalidOperation }
            
            self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
            
            captureSession.removeInput(rearCameraInput)
            
            if captureSession.canAddInput(self.frontCameraInput!) {
                captureSession.addInput(self.frontCameraInput!)
                
                self.currentCameraPosition = .front
            } else {
                throw CameraControllerError.invalidOperation
            }
        }
        
        func switchToRearCamera() throws {
            guard let inputs = captureSession.inputs as? [AVCaptureInput], let frontCameraInput = self.frontCameraInput, inputs.contains(frontCameraInput),
                let rearCamera = self.rearCamera else { throw CameraControllerError.invalidOperation }
            
            self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
            
            captureSession.removeInput(frontCameraInput)
            
            if captureSession.canAddInput(self.rearCameraInput!) {
                captureSession.addInput(self.rearCameraInput!)
                
                self.currentCameraPosition = .rear
            }else {
                throw CameraControllerError.invalidOperation
            }
        }
        
        switch cameraPosition {
        case .front:
            try switchToFrontCamera()

        case .rear:
            try switchToRearCamera()
        }
        
        captureSession.commitConfiguration()
    }
    
    //
    // MARK: - Private section
    //
    
    /* This function creates an AVCaptureVideoPreview using captureSession, sets it to have the portrait orientation, and adds it to the provided view.*/
    func displayPreview( on view: UIView ) throws {
        
        guard let captureSession = self.session, self.session!.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .portrait
        
        view.layer.insertSublayer(self.previewLayer!, at: 0)
        self.previewLayer?.frame = view.frame
    }
    
    /* This function will handle the creation and configuration of a new capture session
     Setting up the capture session consists of 4 steps:
     
     Creating a capture session.
     Obtaining and configuring the necessary capture devices.
     Creating inputs using the capture devices.
     Configuring a photo output object to process captured images.
     */
    func prepare(completionHandler: @escaping (Error?) -> Void) {
        
        func createCaptureSession() {
            self.session = AVCaptureSession()
        }
        
        func configureCaptureDevices() throws {
            
            /*find all of the wide angle cameras available on the current device and convert them into an array of non-optional AVCaptureDevice instances.*/
            let session: AVCaptureDevice.DiscoverySession? = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
            guard let cameras = (session?.devices.compactMap { $0 }), !cameras.isEmpty else { throw CameraControllerError.noCamerasAvailable }
            
            /* This loop looks through the available cameras found in code segment 1 and determines which is the
                front camera and which is the rear camera.
               It additionally configures the rear camera to autofocus, throwing any errors that are encountered along the way.*/
            for camera in cameras {
                if camera.position == .front {
                    self.frontCamera = camera
                }
                
                if camera.position == .back {
                    self.rearCamera = camera
                    
                    try camera.lockForConfiguration()
                    camera.focusMode = .continuousAutoFocus
                    camera.unlockForConfiguration()
                }
            }
        }
        
        func configureDeviceInputs() throws {
            
            //This line simply ensures that captureSession exists. If not, we throw an error.
            guard let captureSession = self.session else { throw CameraControllerError.captureSessionIsMissing }
            
            /*These if statements are responsible for creating the necessary capture device input to support photo capture.
             AVFoundation only allows one camera-based input per capture session at a time. Since the rear camera is
             traditionally the default, we attempt to create an input from it and add it to the capture session.
             If that fails, we fall back on the front camera. If that fails as well, we throw an error.*/
            if let rearCamera = self.rearCamera {
                self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
                
                if captureSession.canAddInput(self.rearCameraInput!) { captureSession.addInput(self.rearCameraInput!) }
                
                self.currentCameraPosition = .rear
            } else if let frontCamera = self.frontCamera {
                self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
                
                if captureSession.canAddInput(self.frontCameraInput!) { captureSession.addInput(self.frontCameraInput!) }
                else { throw CameraControllerError.inputsAreInvalid }
                
                self.currentCameraPosition = .front
            } else {
                throw CameraControllerError.noCamerasAvailable
            }
        }
        
        /*Now we just need a way to get the necessary data out of our capture session. */
        func configurePhotoOutput() throws {
            
            guard let captureSession = self.session else { throw CameraControllerError.captureSessionIsMissing }
            
            self.photoOutput = AVCapturePhotoOutput()
            if #available(iOS 11.0, *) {
                self.photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            } else {
                // Fallback on earlier versions
                log.info( "Fallback on earlier versions" )
            }
            
            if captureSession.canAddOutput(self.photoOutput!) { captureSession.addOutput(self.photoOutput!) }
            
            captureSession.startRunning()
        }
        
        DispatchQueue(label: "prepareCamera").async {
            do {
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configurePhotoOutput()
                
            } catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                return
            }
            
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }
    
    func unprepare() {
        
        func destroyCaptureSession() {
            
            if let session = self.session {
                session.stopRunning()
            }
        }
        
        func deConfigureCaptureDevices() {
            self.frontCamera = nil
            self.rearCamera = nil
            
        }
        
        func deConfigureDeviceInputs() {
            
            if let session = self.session {
                
                if let rearCameraInput = self.rearCameraInput, let inputs = session.inputs as? [AVCaptureInput], inputs.contains(rearCameraInput) {
                    
                    session.removeInput(rearCameraInput)
                    self.rearCameraInput = nil
                }
                
                if let frontCameraInput = self.frontCameraInput, let inputs = session.inputs as? [AVCaptureInput], inputs.contains(frontCameraInput) {
                    session.removeInput(frontCameraInput)
                    self.frontCameraInput = nil
                }
            }
            
        }
        
        func deConfigurePhotoOutput() {
            
            if let session = self.session {
                
                if let photoOutput = self.photoOutput {
                    session.removeOutput(photoOutput)
                    self.photoOutput = nil
                }
            }
        }
        
        DispatchQueue(label: "prepareCamera").async {
            
            destroyCaptureSession()
            deConfigureCaptureDevices()
            deConfigureDeviceInputs()
            deConfigurePhotoOutput()
            
            self.session = nil
        }
    }
    
    //
    // MARK: - Private method, Notification section
    //
    @objc func sessionWasInterrupted() {
        log.info( "SessionWasInterrupted()" )
    }
    
    @objc func sessionInterruptionEnded() {
        log.info( "sessionInterruptionEnded()" )
    }
    
    @objc func sessionRuntimeError() {
        log.info( "sessionRuntimeError()" )
    }
    
}

/* This is a virtual device which is used to mimic the camera while providing images
 */
class TestCameraDevice: CameraDevice {
    
    override var name: String { return "Test\(super.name)" }
    override var canAccess: Bool { return true }
    
    override func requestAccess( completion: @escaping ClosureWithBool ) {
        completion(true)
    }
    
    override func initDevice( with: UIView, params: [String : Any]?, completion: @escaping ClosureWithBool ) {
        _parameters = params
    }
    
    override func deInitDevice( completion:  @escaping ClosureWithBool ) {
        _worker = nil
        _parameters = nil
    }
    
    override func startCapture( completion: @escaping  ClosureWithDeviceDatumStatus ) {
        _worker = completion
        completion( .unknown,Device.status.error  )
    }
    
    override func stopCapture( completion:  @escaping ClosureWithDeviceDatumStatus ) {
        completion( .unknown,Device.status.error  )
    }
    
    override func restart() {
    }
    
}

//
// MARK: Delegate<AVCapturePhotoCaptureDelegate> Extention
//


extension CameraDevice: AVCapturePhotoCaptureDelegate {

    public func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?
                           , previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings
                           , bracketSettings: AVCaptureBracketedStillImageSettings?, error: Swift.Error?) {

        if #available(iOS 12.0, *) {
            if let error = error { self.photoCaptureCompletionBlock?(nil, error) }

            else if let buffer = photoSampleBuffer, let data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: buffer, previewPhotoSampleBuffer: nil), let image = UIImage(data: data) {

                self.photoCaptureCompletionBlock?(image, nil)
            } else {
                self.photoCaptureCompletionBlock?(nil, CameraControllerError.unknown)
            }
        } else {
            // Fallback on earlier versions
            log.info( "Fallback on earlier versions" )
        }
    }

}
