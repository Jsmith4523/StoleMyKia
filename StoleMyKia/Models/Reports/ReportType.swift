//
//  ReportType.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 4/9/23.
//

import Foundation
import UIKit

enum ReportType: String, CaseIterable, Hashable, Identifiable, Codable {
    
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
            return "light.beacon.max.fill"
        case .found:
            return "car.fill"
        case .withnessed:
            return "eye.trianglebadge.exclamationmark.fill"
        case .spotted:
            return "eye.fill"
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
            return ""
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
        }
    }
    
    static var reports: [ReportType] {
        [.stolen, .withnessed, .found]
    }
    
    static var update: [ReportType] {
        [.found, .spotted]
    }
}
