//
//  ReportType.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 4/9/23.
//

import Foundation
import UIKit

enum ReportType: String, CaseIterable, Hashable, Identifiable, Codable {
    
    case carjacked   = "Car Jacking"
    case stolen      = "Stolen"
    case found       = "Found"
    case withnessed  = "Witnessed"
    case spotted     = "Spotted"
    
    var id: String {
        return self.rawValue
    }
    
    var annotationImage: String {
        switch self {
        case .stolen:
            return "car.2.fill"
        case .found:
            return "checkmark.shield"
        case .withnessed:
            return "person.crop.circle.badge.exclamationmark.fill"
        case .spotted:
            return "eye.fill"
        case .carjacked:
            return "light.beacon.max.fill"
        }
    }
    
    ///Use when creating a new report
    var description: String {
        switch self {
        case .stolen:
            return "Your vehicle was stolen and you are reporting it."
        case .found:
            return "You've found a vehicle that was stolen."
        case .withnessed:
            return "You withnessed a vehicle being stolen."
        case .spotted:
            return "eyeglasses"
        case .carjacked:
            return "Your vehicle was stolen by force."
        }
    }
    
    var annotationColor: UIColor {
        switch self {
        case .stolen:
            return .red
        case .found:
            return .purple
        case .withnessed:
            return .systemBlue
        case .spotted:
            return UIColor(.spottedGreen)
        case .carjacked:
            return .red
        }
    }
    
    ///The path a report will be saved to in Google Firebase
    var path: String {
        switch self {
        case .stolen:
            return "stolen"
        case .found:
            return "found"
        case .withnessed:
            return "witnessed"
        case .spotted:
            return "spotted"
        case .carjacked:
            return "carjacked"
        }
    }
    
    var requiresLicensePlateInformation: Bool {
        switch self {
        case .carjacked:
            return true
        case .stolen:
            return true
        case .found:
            return false
        case .withnessed:
            return false
        case .spotted:
            return false
        }
    }
    
    static var reports: [ReportType] {
        [.carjacked, .stolen, .withnessed, .found]
    }
    
    static var update: [ReportType] {
        [.found, .spotted]
    }
}
