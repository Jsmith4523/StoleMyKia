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
    
    case stolen      = "Stolen Vehicle"
    case found       = "Vehicle Found"
    case withnessed  = "Theft Witnessed"
    
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
            return .red
        case .found:
            return .systemBlue
        case .withnessed:
            return .orange
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
    
    var color: UIColor {
        switch self {
        case .red:
            return UIColor(ciColor: CIColor(he))
        case .green:
            return UIColor(ciColor: CIColor(red: <#T##CGFloat#>, green: <#T##CGFloat#>, blue: <#T##CGFloat#>))
        case .blue:
            return UIColor(ciColor: CIColor(red: <#T##CGFloat#>, green: <#T##CGFloat#>, blue: <#T##CGFloat#>))
        case .orange:
            return UIColor(ciColor: CIColor(red: <#T##CGFloat#>, green: <#T##CGFloat#>, blue: <#T##CGFloat#>))
        case .silver:
            return UIColor(ciColor: CIColor(red: <#T##CGFloat#>, green: <#T##CGFloat#>, blue: <#T##CGFloat#>))
        case .black:
            return UIColor(ciColor: CIColor(red: <#T##CGFloat#>, green: <#T##CGFloat#>, blue: <#T##CGFloat#>))
        case .gold:
            return UIColor(ciColor: CIColor(red: <#T##CGFloat#>, green: <#T##CGFloat#>, blue: <#T##CGFloat#>))
        case .gray:
            return UIColor(ciColor: CIColor(red: <#T##CGFloat#>, green: <#T##CGFloat#>, blue: <#T##CGFloat#>))
        case .lightGray:
            return UIColor(ciColor: CIColor(red: <#T##CGFloat#>, green: <#T##CGFloat#>, blue: <#T##CGFloat#>))
        case .brown:
            return UIColor(ciColor: CIColor(red: <#T##CGFloat#>, green: <#T##CGFloat#>, blue: <#T##CGFloat#>))
        case .violet:
            return UIColor(ciColor: CIColor(red: <#T##CGFloat#>, green: <#T##CGFloat#>, blue: <#T##CGFloat#>))
        }
    }
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
