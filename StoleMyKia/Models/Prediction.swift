//
//  Prediction.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 8/7/23.
//

import Foundation

struct Prediction: Codable, Comparable {
    
    
    ///The models confidence level.
    let confidence: Double
    let x: Double
    let y: Double
    /// The width of the detection area.
    let width: Double
    /// The height of the detection area.
    let height: Double
    ///The object class. It'll either be a 'License Plate' or 'VIN'.
    let `class`: String
    ///The image data.
    var imageData: Data?
    
    static func < (lhs: Prediction, rhs: Prediction) -> Bool {
        lhs.confidence < rhs.confidence
    }
    
    static func > (lhs: Prediction, rhs: Prediction) -> Bool {
        lhs.confidence < rhs.confidence
    }
}

extension Prediction {
    
    /// The area where the ML model detected an object
    var detectionArea: CGRect {
        .init(x: self.x,
              y: self.y,
              width: self.width,
              height: self.height)
    }
}
