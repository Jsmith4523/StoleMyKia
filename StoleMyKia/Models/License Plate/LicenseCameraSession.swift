//
//  AVCaptureSession.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 5/1/23.
//

import Foundation
import SwiftUI
import AVKit
import UIKit

struct LicenseCameraSession: UIViewRepresentable {
    
    @ObservedObject var coordinator: LicenseScannerCoordinator
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: context.coordinator.captureSession)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        let pinchZoomGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.updatePinchZoom(_:)))
        view.addGestureRecognizer(pinchZoomGesture)
        
        return view
    }
    
    func makeCoordinator() -> LicenseScannerCoordinator {
        coordinator
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
}


final class LicenseScannerCoordinator: NSObject, ObservableObject {
    
    @Published private(set) var licensePlate = ""
    
    @Published var presentLicenseResultsView = false
        
    @Published var torchIsOn = false
    
    @Published var reports = [Report]()
    
    @Published var captureSession = AVCaptureSession()
    @Published private var device: AVCaptureDevice!
        
    private var zoomFactor: CGFloat = 1.0 {
        didSet {
            self.sendHapticFeedbackForZoomFactor()
        }
    }
    
    var authorization: AVAuthorizationStatus {
        AVCaptureDevice.authorizationStatus(for: .video)
    }
    
    weak var licensePlateDelegate: LicenseScannerDelegate?
    
    func setLicensePlateDelegate(_ delegate: LicenseScannerDelegate) {
        self.licensePlateDelegate = delegate
    }
    
    func checkPermissions() {
        let auth = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch auth {
            
        case .authorized:
            configureSession()
        default:
            askForCameraPermissions()
        }
    }
    
    private func askForCameraPermissions() {
        AVCaptureDevice.requestAccess(for: .video) { success in
            guard success else {
                return
            }
            self.configureSession()
        }
    }
    
    private func sendHapticFeedbackForZoomFactor() {
        if zoomFactor == 1.0 {
            UIImpactFeedbackGenerator().impactOccurred(intensity: 3.0)
        } else if zoomFactor == 120.0 {
            UIImpactFeedbackGenerator().impactOccurred(intensity: 7.0)
        }
    }
    
    func toggleTorch() {
        guard let device else {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            return
        }
        
        try? device.lockForConfiguration()
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        switch torchIsOn {
        case true:
            device.torchMode = .off
            torchIsOn = false
        case false:
            device.torchMode = .on
            torchIsOn = true
        }
        
        device.unlockForConfiguration()
    }
    
    private func configureSession() {
        self.device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back)
        
        guard let device else {
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            guard captureSession.canAddInput(input) else {
                print("Cannot add input")
                return
            }
            
            try? device.lockForConfiguration()
            captureSession.addInput(input)
            device.videoZoomFactor = 1.0
            device.unlockForConfiguration()
            
            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.setSampleBufferDelegate(self, queue: .global(qos: .background))
            
            guard captureSession.canAddOutput(dataOutput) else {
                print("Cannot add output")
                return
            }
            
            captureSession.addOutput(dataOutput)
            
            DispatchQueue.global(qos: .background).async {
                self.captureSession.startRunning()
            }
        } catch {
            print("HAHAHAHA")
        }
    }
    
    ///Will retrieve any current reports that match the license plate string. If not, will retrieve reports from the database and return any that match
    func fetchReports() {
        self.presentLicenseResultsView = true
        licensePlateDelegate?.getReportsWithLicense(licensePlate) { result in
            switch result {
            case .success(let reports):
                self.reports = reports
            case .failure(let reason):
                //TODO: Error out
                break
            }
        }
    }
    
    @objc
    func updatePinchZoom(_ gesture: UIPinchGestureRecognizer) {
        guard let device else {
            return
        }
        
        let maxZoom = device.activeFormat.videoMaxZoomFactor
        let zoom = zoomFactor * gesture.scale
        
        let zoomFactor = max(1.0, min(zoom, maxZoom))
        self.zoomFactor = zoomFactor
        
        //Prevents haptic feedback from behaving sporadically
        if self.zoomFactor == 1.0 || self.zoomFactor == 120.0 {
            gesture.isEnabled = false
        }
        
        gesture.isEnabled = true
        
        try? device.lockForConfiguration()
        device.videoZoomFactor = zoomFactor
        device.unlockForConfiguration()
        
        gesture.scale = 1.0
    }
}

//MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension LicenseScannerCoordinator: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        //TODO: Setup License Plate detection model
    }
}

enum LicenseScannerError: String, Error {
    case noReports = "There are no active reports for that license plate."
    case networkError = "There was an error finding reports that contain that license plate."
}

protocol LicenseScannerDelegate: AnyObject {
    func getReportsWithLicense(_ licenseString: String, completion: @escaping ((Result<[Report], LicenseScannerError>)->Void))
}
