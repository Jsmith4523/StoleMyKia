//
//  Report.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/11/23.
//

import Foundation
import UIKit
import MapKit

enum ReportType: String, CaseIterable, Codable {
    
    case stolen      = "Stolen"
    case found       = "Found"
    case withnessed  = "Witnessed"
    
    var annotationImage: String {
        switch self {
        case .stolen:
            return "light.beacon.max.fill"
        case .found:
            return "car.fill"
        case .withnessed:
            return "exclamationmark.triangle.fill"
        }
    }
    
    var annotationColor: UIColor {
        switch self {
        case .stolen:
            return UIColor.red
        case .found:
            return UIColor.systemBlue
        case .withnessed:
            return UIColor.systemOrange
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
    let vehicleYear: Int
    let vehicleDescription: String
    let lat: Double
    let lon: Double
}

extension Report {
    
    var coordinates: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    ///Affected vehicle years of both Kia's and Hyundai's
    static var affectedVehicleYears: ClosedRange<Int> {
        return 2011...2022
    }
}
