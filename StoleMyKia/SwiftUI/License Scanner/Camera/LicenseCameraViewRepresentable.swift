//
//  LicenseScannerCameraView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/13/23.
//

import Foundation
import UIKit
import AVKit
import CoreML
import SwiftUI

struct LicenseCameraViewRepresentable: UIViewRepresentable {
    
    @ObservedObject var scannerCoordinator: LicensePlateScannerCoordinator
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        if let layer = context.coordinator.previewLayer {
            layer.frame = view.bounds
            layer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(layer)
        }
        return view
    }
    
    static func dismantleUIView(_ uiView: UIView, coordinator: LicensePlateScannerCoordinator) {
        
    }
    
    func makeCoordinator() -> LicensePlateScannerCoordinator {
        scannerCoordinator
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

final class LicensePlateScannerCoordinator: NSObject, ObservableObject {
    
    enum CameraPermissionAccess {
        case authorized, denied, pending
    }
    
    enum LicensePlateDetectionError {
        case captureError, objectDetectionError, textError
    }
    
    //AVSession properties...
    @Published private var captureOutput: AVCapturePhotoOutput!
    @Published private var captureSession: AVCaptureSession!
    @Published private(set) var previewLayer: AVCaptureVideoPreviewLayer!
    @Published var zoomAmount: Double = 0.0
    
    @Published private(set) var alertErrorFetchingReports = false
    @Published private(set) var errorReason: LicenseScannerError?
    
    @Published private(set) var isFetchingReports = false
    
    ///The array of reports that match the license plate string
    @Published private(set) var reports = [Report]()
    
    ///The string value of the license plate.
    @Published private(set) var licensePlateString = ""
    ///The cropped image of the license plate.
    @Published var croppedLicensePlateImage: UIImage?
    
    ///Device camera permission access. Used to switch between multiple views if needed.
    @Published private(set) var permissionAccess: CameraPermissionAccess = .pending
    
    weak private var licensePlateScannerDelegate: LicensePlateCoordinatorDelegate?
    
    private let licensePlateDetectionManager = LicensePlateDetectionManager()
    private let licenseTextDetectionManager = LicenseTextDetectionManager()
        
    override init() {
        super.init()
        licensePlateDetectionManager.setDelegate(licenseTextDetectionManager)
        licenseTextDetectionManager.setDelegate(self)
    }
        
    func setDelegate(_ delegate: LicensePlateCoordinatorDelegate) {
        self.licensePlateScannerDelegate = delegate
    }
    
    //Check permission and setup camera if authorized
    private func authorizationStatus() -> AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: .video)
    }
    
    func setupCamera() {
        guard authorizationStatus() == .authorized else {
            return
        }
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            return
        }
        
        let session = AVCaptureSession()
        self.captureSession = session
                
        captureSession.beginConfiguration()
        
        guard let deviceInput = try? AVCaptureDeviceInput(device: device) else {
            return
        }
                
        guard let captureSession, captureSession.canAddInput(deviceInput) else {
            return
        }
        
        captureSession.addInput(deviceInput)
        captureSession.commitConfiguration()
        
        setPreviewLayer()
        setupVideoOutput()
        
        func setPreviewLayer() {
            self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        }
        
        func setupVideoOutput() {
            let output = AVCapturePhotoOutput()
            
            guard captureSession.canAddOutput(output) else { return }
            captureSession.addOutput(output)
            
            self.captureOutput = output
            resumeCameraSession()
        }
    }
    
    func askForPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] _ in
            //Recheck the current permissions...
            self?.setupCamera()
        }
    }
    
    ///Resumes the current camera session through the background thread.
    func resumeCameraSession() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let captureSession = self?.captureSession else { return }
            captureSession.startRunning()
        }
    }
    
    ///Suspends the current camera session through the background thread.
    func suspendCameraSession() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let captureSession = self?.captureSession else { return }
            captureSession.stopRunning()
        }
    }
    
    ///Captures the image and sends it to LicenseDetectionManager for detection onced finished processing
    func captureImage() {
        let captureSettings = AVCapturePhotoSettings()
        
        guard let captureOutput else {
            return
        }
        
        captureOutput.capturePhoto(with: captureSettings, delegate: self)
        //suspendCameraSession()
    }
    
    deinit {
        licensePlateScannerDelegate = nil
        licensePlateDetectionManager.prepareCleanUp()
        print("Dead: LicensePlateScannerCoordinator")
    }
}


//MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension LicensePlateScannerCoordinator: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            licensePlateDetectionManager.detect(data: imageData)
        }
    }
}

//MARK: - LicenseTextDetectionDelegate
extension LicensePlateScannerCoordinator: LicenseTextDetectionDelegate {
    func didSuccessfullyLocateLicensePlateText(_ textString: String, prediction: Prediction) {
        print("Did successfully detect License Plate Text: \(textString)")
        if let imageData = prediction.imageData, let image = UIImage(data: imageData)?.cropToRect(rect: prediction.detectionArea) {
            self.croppedLicensePlateImage = image
        }
    }
    
    func didFailToLocateLicensePlateText() {
        print("Did not detect License Plate Text")
    }
    
    func didDetectLicensePlate(_ prediction: Prediction) {
        print("Detected License Plate: Confidence is \(prediction.confidence)")

    }
    func didFailToDetectLicensePlate() {
        print("Did not detect License Plate")
    }
}
