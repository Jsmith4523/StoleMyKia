//
//  LicenseTextDetectionManager.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 7/14/23.
//

import Foundation
import UIKit
import Vision
import VisionKit

class LicenseTextDetectionManager {
    
    weak private var textDetectionDelegate: LicenseTextDetectionDelegate?
    private var prediction: Prediction!
    
    func setDelegate(_ delegate: LicenseTextDetectionDelegate) {
        self.textDetectionDelegate = delegate
    }
    
    /// Start detecting for text in the image.
    /// - Parameter image: The UIImage to detect text from.
    private func detectText(_ image: UIImage, prediction: Prediction) throws {
        guard let cgImage = image.cgImage else {
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: .up)
        let request = VNRecognizeTextRequest(completionHandler: textHandler)
        
        try requestHandler.perform([request])
    }
    
    private func textHandler(request: VNRequest, error: Error?) {
        guard error == nil else {
            return
        }
          
        guard let observations = request.results as? [VNRecognizedTextObservation] else {
            textDetectionDelegate?.didFailToLocateLicensePlateText()
            return
        }
        
        let recognizedStrings = observations.compactMap({$0.topCandidates(1).first?.string})
        
        guard let bestString = recognizedStrings.first else {
            textDetectionDelegate?.didFailToLocateLicensePlateText()
            return
        }
        
        textDetectionDelegate?.didSuccessfullyLocateLicensePlateText(bestString, prediction: prediction!)
    }
    
    deinit {
        self.textDetectionDelegate = nil
        print("Dead: LicenseTextDetectionManager")
    }
}

//MARK: - LicensePlateDetectionDelegate
extension LicenseTextDetectionManager: LicensePlateDetectionDelegate {
    func didDetectLicensePlate(_ prediction: Prediction) {
        self.prediction = prediction
        
        guard let data = prediction.imageData else {
            textDetectionDelegate?.didFailToDetectLicensePlate()
            return
        }
            
        guard let image = UIImage(data: data) else {
            textDetectionDelegate?.didFailToDetectLicensePlate()
            return
        }
        
        guard let croppedImage = image.cropToRect(rect: prediction.detectionArea) else {
            textDetectionDelegate?.didFailToDetectLicensePlate()
            return
        }
        
        do {
            //Begin detecting text within the cropped image
            try detectText(image, prediction: prediction)
        } catch {
            print("Detection Error: \(error.localizedDescription)")
        }
    }
    
    func didFailToDetectLicensePlate() {
        textDetectionDelegate?.didFailToDetectLicensePlate()
    }
}

protocol LicenseTextDetectionDelegate: LicensePlateDetectionDelegate {
    func didSuccessfullyLocateLicensePlateText(_ textString: String, prediction: Prediction)
    func didFailToLocateLicensePlateText()
}
