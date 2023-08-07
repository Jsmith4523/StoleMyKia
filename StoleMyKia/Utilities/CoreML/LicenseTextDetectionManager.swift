//
//  LicenseTextDetectionManager.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 7/14/23.
//

import Foundation
import UIKit
import VisionKit

class LicenseTextDetectionManager {
    
    weak private var textDetectionDelegate: LicenseTextDetectionDelegate?
    
    func setDelegate(_ delegate: LicenseTextDetectionDelegate) {
        self.textDetectionDelegate = delegate
    }
    
    private func extractLicenseFromImage() {
        
    }
    
    deinit {
        self.textDetectionDelegate = nil
        print("Dead: LicenseTextDetectionManager")
    }
}

//MARK: - LicensePlateDetectionDelegate
extension LicenseTextDetectionManager: LicensePlateDetectionDelegate {
    func didLocateLicensePlate(image: UIImage) {
        self.textDetectionDelegate?.didLocateLicensePlateString("", image: image)
    }
    
    func didFailToLocateLicensePlate() {
        self.textDetectionDelegate?.didFailToLocateLicensePlate()
    }
    
    func didFailToConfigure() {
        self.textDetectionDelegate?.didFailToConfigure()
    }
}

protocol LicenseTextDetectionDelegate: LicensePlateDetectionDelegate {
    func didLocateLicensePlateString(_ licenseString: String, image: UIImage)
}
