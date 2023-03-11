//
//  Report.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/11/23.
//

import Foundation
import UIKit

enum ReportType: String, CaseIterable, Codable {
    
    case stolen      = "Stolen"
    case found       = "Found"
    case withnessed  = "Withnessed"
    
    var annotationImage: String {
        switch self {
        case .stolen:
            return "light.beacon.max.fill"
        case .found:
            return "car.fill"
        case .withnessed:
            return "figure.run"
        }
    }
    
    var annotationColor: UIColor {
        switch self {
        case .stolen:
            return UIColor.red
        case .found:
            return UIColor.green
        case .withnessed:
            return UIColor.orange
        }
    }
}

enum VehicleColor: String, CaseIterable, Codable {
    case red       = "Red"
    case green     = "Green"
    case blue      = "Blue"
    case orange    = "Orange"
    case silver    = "Silver"
    case black     = "Black"
    case gold      = "Gold"
    case gray      = "Gray"
    case lightGray = "Light Gray"
    case brown     = "Brown"
    case violet    = "Violet"
}

enum VehicleMake: String, CaseIterable, Codable {
    case hyundai = "Hyundai"
    case kia = "Kia"
}

struct Report: Identifiable, Codable {
    var id = UUID()
    let title: String
    let description: String
    let reportType: ReportType
    let vehicleMake: VehicleMake
    let vehicleColor: VehicleColor
    let vehicleDescription: String
}
