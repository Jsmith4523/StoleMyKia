//
//  LicensePlateTextScanner.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 7/8/23.
//

import Foundation
import VisionKit
import Vision
import CoreML

///Handles VNRequests of Vehicle License Plates
class LicensePlateDetectionManager {
    
    private var image: UIImage?
        
    weak private var detectionDelegate: LicensePlateDetectionDelegate?
        
    func setDelegate(_ delegate: LicensePlateDetectionDelegate) {
        self.detectionDelegate = delegate
        //setupDetectionModelRequest()
    }
    
    func detect(data: Data) {
        if let image = UIImage(data: data) {
            let jpegImageData = image.jpegData(compressionQuality: 1)
            let content = jpegImageData?.base64EncodedString()
            let contentData = content!.data(using: .utf8)
            
            Task {
                do {
                    let imageData = data
                    try await performDetectionRequest(data: contentData, imageData: data)
                } catch {
                    print("Error throw")
                }
            }
        }
    }
    
    /// Perform Roboflow API object detection request.
    /// - Parameters:
    ///   - data: The content data to be evaluated.
    ///   - imageData: The Image data to be passed to LicenseTextDetectionManager once predictions are received.
    @MainActor
    private func performDetectionRequest(data: Data?, imageData: Data?) async throws {
        guard let data else { return }
        
        var request = URLRequest(url: URL(string: "https://detect.roboflow.com/smk-license-plates/1?api_key=U1vHYYUNiHZ0CJ8B5RfL&name=YOUR_IMAGE.jpg")!,timeoutInterval: Double.infinity)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = data
        
        let (networkData, _) = try await URLSession.shared.data(for: request)
        guard let json = try JSONSerialization.jsonObject(with: networkData) as? [String: Any], let jsonPredictions = json["predictions"] as? [[String: Any]] else {
            return
        }
                
        let predictions = jsonPredictions.compactMap({JSONSerialization.objectFromData(Prediction.self, jsonObject: $0)}).sorted(by: >)
                
        guard let firstPrediction = predictions.first else {
            return
        }
        
        var bestPrediction = firstPrediction
        bestPrediction.imageData = imageData
        
        detectionDelegate?.didDetectLicensePlate(bestPrediction)
    }
    
    func prepareCleanUp() {
        //detectionRequest = nil
    }
    
    deinit {
        detectionDelegate = nil
        print("Dead: LicensePlateDetectionDelegate")
    }
}

protocol LicensePlateDetectionDelegate: AnyObject {
    func didDetectLicensePlate(_ prediction: Prediction)
    func didFailToDetectLicensePlate()
}
