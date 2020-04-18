//
//  VideoCameraDevice.swift
//  GMI
//
//  Created by Dana Le Rhae De Voe on 8/14/19.
//  Copyright © 2019 Bruce Daniel. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

/* This camera is designed to to video setup for the camera.  */
class VideoCameraDevice: CameraDevice {
    
    //
    //MARK:- DeviceProtocol members
    //
    override var name: String { get { return "videocamera"} }
    var videoDataOutput: AVCaptureVideoDataOutput?
    
    override func deInitDevice( completion:  @escaping ClosureWithBool ) {
        
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
            completion( false )
            return
        }
        
        if let session = self.session, let videoDataOutput = self.videoDataOutput{
            session.removeOutput(videoDataOutput)
            
            self.videoDataOutput = nil
        }
        
        super.deInitDevice( completion: completion )// must be called last because it set self.session to nil
    }
    
    
    /* This function will handle the creation and configuration of a new capture session
     Setting up the capture session consists of 4 steps:
     
     Creating a capture session.
     Obtaining and configuring the necessary capture devices.
     Creating inputs using the capture devices.
     Configuring a photo output object to process captured images.
     */
    override func prepare(completionHandler: @escaping (Error?) -> Void) {
        
        func createCaptureSession() {
            self.session = AVCaptureSession()
        }
        
        func configureVideo() {
            
            //let opts = [ CIDetectorAccuracy : CIDetectorAccuracyHigh ]
            self.context = CIContext(options: nil)
            
            self.videoDataOutput = AVCaptureVideoDataOutput()
            self.videoDataOutput?.alwaysDiscardsLateVideoFrames = true
            
            self.videoDataOutputQueue = DispatchQueue(label: "com.imageware.serialq.video")
            
            self.videoDataOutput?.setSampleBufferDelegate(self, queue: self.videoDataOutputQueue)
            
            if self.session!.canAddOutput(self.videoDataOutput!) {
                self.session?.addOutput(self.videoDataOutput!)
            }
            
            self.videoDataOutput?.connection(with:.video)
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
                log.error( "Fall back on earlier versions???" )
                // Fallback on earlier versions
            }
            
            if captureSession.canAddOutput(self.photoOutput!) { captureSession.addOutput(self.photoOutput!) }
            
            captureSession.startRunning()
        }
        
        DispatchQueue(label: "prepareCamera").async {
            do {
                createCaptureSession()
                configureVideo()
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
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    }
    
    
}
