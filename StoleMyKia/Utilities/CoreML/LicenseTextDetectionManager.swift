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
    
    weak private var textDectectionDelegate: LicenseTextDetectionDelegate?
    
    func setDelegate(_ delegate: LicenseTextDetectionDelegate) {
        self.textDectectionDelegate = delegate
    }
    
    private func extractLicenseFromImage() {
        
    }
    
    deinit {
        textDectectionDelegate = nil
        print("Dead: LicenseTextDetectionManager")
    }
}

//MARK: - LicensePlateDetectionDelegate
extension LicenseTextDetectionManager: LicensePlateDetectionDelegate {
    func didLocateLicensePlate(image: UIImage) {
        self.textDectectionDelegate?.didLocateLicensePlateString("", image: image)
    }
    
    func didFailToLocateLicensePlate() {
        
    }
    
    func didFailToConfigure() {
        
    }
}

protocol LicenseTextDetectionDelegate: LicensePlateDetectionDelegate {
    func didLocateLicensePlateString(_ licenseString: String, image: UIImage)
}
