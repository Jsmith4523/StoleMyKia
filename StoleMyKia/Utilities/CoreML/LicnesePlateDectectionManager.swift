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
class LicnesePlateDectectionManager {
    
    private var image: UIImage?
    
    private var dectectionRequest: VNCoreMLRequest?
    
    weak private var detectionDelegate: LicensePlateDetectionDelegate?
        
    init() {
        setupDetectionModelRequest()
    }
    
    func setDelegate(_ delegate: LicensePlateDetectionDelegate) {
        self.detectionDelegate = delegate
    }
    
    private func setupDetectionModelRequest() {
        do {
            let detectionModel = try SMKLicensePlateDetector(configuration: MLModelConfiguration())
            let model = try VNCoreMLModel(for: detectionModel.model)
                    
            self.dectectionRequest = VNCoreMLRequest(model: model, completionHandler: requestCompleted)
        } catch {
            detectionDelegate?.didFailToConfigure()
        }
    }
    
    private func requestCompleted(request: VNRequest, error: Error?) {
        guard error == nil else {
            detectionDelegate?.didFailToConfigure()
            return
        }
                
        guard let results = request.results as? [VNRectangleObservation] else {
            detectionDelegate?.didFailToLocateLicensePlate()
            return
        }
        
        //Getting the best prediction
        guard let bestPrediction = results.first else {
            detectionDelegate?.didFailToLocateLicensePlate()
            return
        }
        
        //Returning the bounding-box location so Vision can detect the license plate text
        let detectionBoundingLocation = bestPrediction.boundingBox
        
        guard let image, let croppedImage = image.cropToRect(rect: detectionBoundingLocation) else {
            detectionDelegate?.didFailToLocateLicensePlate()
            return
        }
        
        detectionDelegate?.didLocateLicensePlate(image: croppedImage)
    }
    
    func beginDetection(_ image: CIImage) {
        do {            
            guard !(detectionDelegate == nil) else {
                fatalError("LicensePlateDetectionDelegate not set!")
            }
            
            guard let dectectionRequest else {
                return
            }
            
            let imageDectectionRequest = VNImageRequestHandler(ciImage: image, orientation: .up, options: [:])
            try imageDectectionRequest.perform([dectectionRequest])
            
        } catch {
            detectionDelegate?.didFailToLocateLicensePlate()
        }
    }
    
    deinit {
        detectionDelegate = nil
        print("Dead: LicensePlateDetectionDelegate")
    }
}

protocol LicensePlateDetectionDelegate: AnyObject {
    ///Called when the VNRequest did detect a License Plate
    func didLocateLicensePlate(image: UIImage)
    ///Called when the CoreML model could not locate an License Plate.
    func didFailToLocateLicensePlate()
    ///Called when the CoreML model failed to configure.
    func didFailToConfigure()
}
