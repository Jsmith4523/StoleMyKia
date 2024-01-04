//
//  ReportType.swift
//  SMKNotificationMapContent
//
//  Created by Jaylen Smith on 12/31/23.
//

import Foundation
import UIKit

enum ReportType: String, Decodable {
    
    static let updateCases: [Self] = [.found, .witnessed, .incident, .located]
    
    case attempt     = "Attempt"
    case carjacked   = "Car Jacking"
    case stolen      = "Stolen"
    case found       = "Recovered"
    case witnessed   = "Witnessed"
    case located     = "Located"
    case breakIn     = "Break-In"
    case incident    = "Incident"
    
    ///Raw value
    var id: String {
        return self.rawValue
    }
    
    var symbol: String {
        self.annotationImage
    }
    
    var annotationImage: String {
        switch self {
        case .stolen:
            return "light.beacon.max.fill"
        case .found:
            return "checkmark.shield.fill"
        case .witnessed:
            return "eye.fill"
        case .located:
            return "car.fill"
        case .carjacked:
            return "light.beacon.max.fill"
        case .attempt:
            return "exclamationmark.triangle"
        case .breakIn:
            return "screwdriver.fill"
        case .incident:
            return "figure.run"
        }
    }
    
    ///The map annotation color (or just associated color with this report type)
    var annotationColor: UIColor {
        switch self {
        case .stolen:
            return .red
        case .found:
            return .purple
        case .witnessed:
            return .red
        case .located:
            return .purple
        case .carjacked:
            return .red
        case .attempt:
            return .orange
        case .breakIn:
            return .systemOrange
        case .incident:
            return .red
        }
    }
}
