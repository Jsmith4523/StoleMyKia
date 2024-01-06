//
//  CarLicenseScannerViewModel.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 1/2/24.
//

import Foundation
import UIKit
import AVFoundation

final class CarLicenseScannerViewModel: NSObject, ObservableObject {
    
    enum ScannerCaptureMode {
        case scan, preview(UIImage)
    }
    
    //MARK: Properties
    @Published var presentAlert = false
    @Published private(set) var licensePlateDetected = false
    @Published private(set) var alertError: ScannerError? {
        didSet {
            self.presentAlert.toggle()
        }
    }
    
    @Published private(set) var captureMode: ScannerCaptureMode = .scan
    @Published private(set) var flashMode: AVCaptureDevice.TorchMode = .off
    
    //MARK: Capture Properties
    @Published private(set) var captureSession: AVCaptureSession!
    @Published private(set) var preview: AVCaptureVideoPreviewLayer!
    
    private var videoDeviceInput: AVCaptureDeviceInput!
    private var photoCaptureOutput: AVCapturePhotoOutput!
    private var captureDevice: AVCaptureDevice!
    
    private let sessionQueue = DispatchQueue(label: "session_queue", qos: .userInteractive)
    private let modelQueue = DispatchQueue(label: "model_queue", qos: .userInteractive)
    
    override init() {
        self.preview = AVCaptureVideoPreviewLayer()
        super.init()
    }
    
    private func setupCamera() {
        do {
            let captureSession = AVCaptureSession()
            captureSession.beginConfiguration()
            captureSession.sessionPreset = .hd1920x1080
            
            let captureDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back)
            
            guard let captureDevice else { throw ScannerError.captureDeviceError }
            
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            
            guard captureSession.canAddInput(captureDeviceInput) else { throw ScannerError.captureDeviceError }
            captureSession.addInput(captureDeviceInput)
            
            self.preview.session = captureSession
            
            let videoDataOutput = AVCaptureVideoDataOutput()
            videoDataOutput.setSampleBufferDelegate(self, queue: sessionQueue)
            let photoCaptureOutput = AVCapturePhotoOutput()
            
            guard captureSession.canAddOutput(videoDataOutput), captureSession.canAddOutput(photoCaptureOutput) else { throw ScannerError.captureOutputError }
            
            captureSession.addOutput(videoDataOutput)
            captureSession.addOutput(photoCaptureOutput)
            
            videoDataOutput.connection(with: .video)?.videoOrientation = .portrait
            photoCaptureOutput.connection(with: .video)?.videoOrientation = .portrait
            
            captureSession.commitConfiguration()
            
            self.captureDevice      = captureDevice
            self.videoDeviceInput   = captureDeviceInput
            self.photoCaptureOutput = photoCaptureOutput
            self.captureSession     = captureSession
            
            sessionQueue.async {
                captureSession.startRunning()
            }
        } catch {
            displayError(.genericError)
        }
    }
    
    func toggleDeviceFlash() {
        guard let captureDevice else { return }
        try? captureDevice.lockForConfiguration()
        captureDevice.torchMode = captureDevice.torchMode == .on ? .off : .on
        self.flashMode = captureDevice.torchMode
        captureDevice.unlockForConfiguration()
    }
    
    func captureLicensePlate() {
        guard let photoCaptureOutput else { return }
        let settings = AVCapturePhotoSettings()
        photoCaptureOutput.capturePhoto(with: settings, delegate: self)
    }
}

//MARK: - AVCapturePhotoCaptureDelegate
extension CarLicenseScannerViewModel: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) else {
            self.displayError(.captureOutputError)
            return
        }
        
        self.captureMode = .preview(image)
    }
}

//MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CarLicenseScannerViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
    }
}

extension CarLicenseScannerViewModel {
    
    enum ScannerError: Error {
        case notAuthorized, genericError, captureDeviceError, captureOutputError
    }
    
    func checkAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            
        case .notDetermined:
            self.askForAuthorization()
        case .restricted:
            self.displayError(.notAuthorized)
        case .denied:
            self.displayError(.notAuthorized)
        case .authorized:
            sessionQueue.async {
                self.setupCamera()
            }
        @unknown default:
            self.askForAuthorization()
        }
    }
    
    private func askForAuthorization() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] success in
            guard success else {
                self?.displayError(.notAuthorized)
                return
            }
            self?.checkAuthorization()
        }
    }
    
    private func displayError(_ error: ScannerError = .genericError) {
        DispatchQueue.main.async {
            self.alertError = error
        }
    }
}
