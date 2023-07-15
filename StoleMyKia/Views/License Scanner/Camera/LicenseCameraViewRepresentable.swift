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
        let view = UIView()
        
        if let layer = context.coordinator.previewLayer {
            layer.frame = view.bounds
            layer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(layer)
        }
                
        return view
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
    
    @Published private(set) var alertErrorFetchingReports = false
    @Published private(set) var errorReason: LicenseScannerError?
    
    @Published private(set) var isFetchingReports = false
    
    ///The array of reports that match the license plate string
    @Published private(set) var reports = [Report]()
    
    ///The string value of the license plate.
    @Published private(set) var licensePlateString = ""
    ///The cropped image of the license plate.
    @Published private(set) var croppedLicensePlateImage: UIImage?
    
    ///Device camera permission access. Used to switch between multiple views if needed.
    @Published private(set) var permissionAccess: CameraPermissionAccess = .pending
    
    weak private var licensePlateScannerDelegate: LicensePlateCoordinatorDelegate?
    
    private let licensePlateDetectionManager = LicnesePlateDectectionManager()
    private let licenseTextDectectionManager = LicenseTextDetectionManager()
        
    override init() {
        super.init()
        self.checkPermissions()
        
        licensePlateDetectionManager.setDelegate(licenseTextDectectionManager)
        licenseTextDectectionManager.setDelegate(self)
    }
        
    func setDelegate(_ delegate: LicensePlateCoordinatorDelegate) {
        self.licensePlateScannerDelegate = delegate
    }
    
    private func checkPermissions() {
        DispatchQueue.main.async {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                self.permissionAccess = .authorized
            case .denied:
                self.permissionAccess = .denied
            case .restricted:
                self.permissionAccess = .pending
            case .notDetermined:
                self.permissionAccess = .pending
            default:
                self.permissionAccess = .denied
            }
        }
    }
    
    private func setupCamera() {
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
        
        func setupVideoOutput() {
            let output = AVCapturePhotoOutput()
            
            guard captureSession.canAddOutput(output) else { return }
            captureSession.addOutput(output)
        }
        
        @MainActor
        func setPreviewLayer() {
            self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        }
    }
    
    func askForPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] _ in
            //Recheck the current permissions...
            self?.checkPermissions()
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
    }
    
    deinit {
        licensePlateScannerDelegate = nil
        print("Dead: LicensePlateScannerCoordinator")
    }
}


//MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension LicensePlateScannerCoordinator: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let photoPixies = photo.pixelBuffer else { return }
                
        let ciImage = CIImage(cvPixelBuffer: photoPixies)
        licensePlateDetectionManager.beginDetection(ciImage)
    }
}

//MARK: - LicenseTextDetectionDelegate
extension LicensePlateScannerCoordinator: LicenseTextDetectionDelegate {
    func didLocateLicensePlateString(_ licenseString: String, image: UIImage) {
        self.licensePlateString = licenseString
        self.croppedLicensePlateImage = image
    }
    
    func didLocateLicensePlate(image: UIImage) {}
    
    func didFailToLocateLicensePlate() {
        
    }
    
    func didFailToConfigure() {
        
    }
}
