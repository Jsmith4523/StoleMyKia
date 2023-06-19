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
        UIView()
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
    
    @Published private(set) var alertErrorFetchingReports = false
    @Published private(set) var errorReason: LicenseScannerError?
    
    @Published private(set) var isFetchingReports = false
    
    ///The array of reports that match the license plate string
    @Published private(set) var reports = [Report]()
    
    ///The matching string the license plate ML model captured
    @Published private(set) var licensePlateString = ""
    
    ///Device camera permission access. Used to switch between multiple views if needed
    @Published private(set) var permissionAccess: CameraPermissionAccess = .pending
    
    override init() {
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
    
    weak private var licensePlateScannerDelegate: LicenseScannerDelegate?
    
    func setDelegate(_ delegate: LicenseScannerDelegate) {
        self.licensePlateScannerDelegate = delegate
    }
    
    func askForPermission() {
        AVCaptureDevice.requestAccess(for: .video) { _ in }
    }
    
    func setupCamera() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            return
        }
        
        guard let deviceInput = try? AVCaptureDeviceInput(device: device) else {
            return
        }
        
        let captureSession = AVCaptureSession()
        
        guard captureSession.canAddInput(deviceInput) else {
            return
        }
        
        //TODO: Setup Output to License Plate Scanner CoreML model
    }
    
    func fetchReportsThatMatchLicenseString() {
        self.isFetchingReports = true
        
        licensePlateScannerDelegate?.getReportsWithLicense(self.licensePlateString) { [weak self] result in
            switch result {
            case .success(let reports):
                self?.reports = reports
                self?.isFetchingReports = false
            case .failure(let error):
                self?.alertErrorFetchingReports = true
                self?.errorReason = error
            }
        }
    }
    
    ///Resumes the current camera session through the background thread
    func resumeCameraSession() {
        
    }
    
    ///Suspends the current camera session through the background thread
    func suspendCameraSession() {
        
    }
    
    deinit {
        licensePlateScannerDelegate = nil
        print("Dead: LicensePlateScannerCoordinator")
    }
}

