//
//  Report.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/11/23.
//

import Foundation
import UIKit
import MapKit
import CryptoKit

enum ReportType: String, CaseIterable, Hashable, Codable {
    
    case stolen      = "Stolen"
    case found       = "Found"
    case withnessed  = "Witnessed"
    case spotted     = "Spotted"
    
    var annotationImage: String {
        switch self {
        case .stolen:
            return "light.beacon.max.fill"
        case .found:
            return "car.fill"
        case .withnessed:
            return "exclamationmark.triangle.fill"
        case .spotted:
            return "eye.fill"
        }
    }
    
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
            return .tintColor
        case .withnessed:
            return .systemOrange
        case .spotted:
            return .green
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

enum VehicleColor: String, CaseIterable, Codable {
    case red       = "Red"
    case white     = "White"
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

//MARK: Vehicles affected based from NTSB
//2015-2021 Hyundai Accent (all body styles)
//2015-2021 Hyundai Elantra (two-door and four-door)
//2015-2021 Hyundai Kona
//2015-2021 Hyundai Santa Fe
//2015-2021 Hyundai Tucson
//2015-2018 Hyundai Veloster
//2015-2021 Kia Forte
//2015-2021 Kia Optima
//2015-2016 Kia Optima Hybrid
//2015-2021 Kia Rio (all body styles)
//2015-2021 Kia Sedona
//2015-2016 Kia Sorento
//2015-2021 Kia Soul
//2015-2021 Kia Sportage

enum VehicleModel: String, CaseIterable, Codable, Comparable {
    
    //MARK: - Hyundai Vehicles
    case accent   = "Accent"
    case elantra  = "Elantra"
    case kona     = "Kona"
    case santaFe  = "Santa Fe"
    case tuscon   = "Tuscon"
    case veloster = "Veloster"
    case sonata   = "Sonata"
    case venue    = "Venue"
    
    //MARK: - Kia Vehicles
    case forte    = "Forte"
    case rio      = "Rio"
    case optima   = "Optima"
    case soul     = "Soul"
    case sportage = "Sportage"
    case sorento  = "Sorento"
    case seltos   = "Seltos"
    
    ///Vehicle make (ex: Hyundai Elantra)
    var make: VehicleMake {
        switch self {
            
        case .accent:
            return .hyundai
        case .elantra:
            return .hyundai
        case .kona:
            return .hyundai
        case .santaFe:
            return .hyundai
        case .tuscon:
            return .hyundai
        case .veloster:
            return .hyundai
        case .sonata:
            return .hyundai
        case .venue:
            return .hyundai
        case .forte:
            return .kia
        case .rio:
            return .kia
        case .optima:
            return .kia
        case .soul:
            return .kia
        case .sportage:
            return .kia
        case .sorento:
            return .kia
        case .seltos:
            return .kia
        }
    }
    
    ///The current affected year range of a vehicle. This many change in the future because Hyundai!!!
    var year: ClosedRange<Int> {
        switch self {
        case .accent:
            return 2011...Report.lastAffectedYear
        case .elantra:
            return 2011...Report.lastAffectedYear
        case .kona:
            return 2018...Report.lastAffectedYear
        case .santaFe:
            return 2011...Report.lastAffectedYear
        case .tuscon:
            return 2011...Report.lastAffectedYear
        case .veloster:
            return 2011...Report.lastAffectedYear
        case .sonata:
            return 2011...Report.lastAffectedYear
        case .venue:
            return 2019...Report.lastAffectedYear
        case .forte:
            return 2011...Report.lastAffectedYear
        case .rio:
            return 2011...Report.lastAffectedYear
        case .optima:
            return 2011...Report.lastAffectedYear
        case .soul:
            return 2011...Report.lastAffectedYear
        case .sportage:
            return 2011...Report.lastAffectedYear
        case .sorento:
            return 2011...Report.lastAffectedYear
        case .seltos:
            return 2019...Report.lastAffectedYear
        }
    }
    
    static func < (lhs: VehicleModel, rhs: VehicleModel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    static func > (lhs: VehicleModel, rhs: VehicleModel) -> Bool {
        lhs.rawValue > rhs.rawValue
    }
    
    ///Will return a vehicle to the given arguments if the conditions do not match. 
    func matches(make: VehicleMake, year: Int) -> Self {
        if (self.make == make && self.year.contains(year)) {
            return self
        } else if !(self.year.contains(year)) {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            return Self.allCases.filter(make, year).first!
        }
        else {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            return Self.allCases.filter(make, year).first!
        }
    }
}

struct Report: Identifiable, Codable {
    var id = UUID()
    
    let dt: TimeInterval?
    let reportType: ReportType?
    let vehicleYear: Int?
    let vehicleMake: VehicleMake?
    let vehicleColor: VehicleColor?
    let vehicleModel: VehicleModel?
    let licensePlate: EncryptedData?
    let vin: EncryptedData?
    var imageURL: String?
    var isFound: Bool?
    let lat: Double
    let lon: Double
}

extension Report {
    
    var coordinates: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    var type: String {
        if let reportType {
            return reportType.rawValue
        }
        return ""
    }
    
    var vehicleDetails: String {
        if let vehicleYear, let vehicleMake, let vehicleModel, let vehicleColor {
            return "\(vehicleColor.rawValue) \(vehicleYear) \(vehicleMake.rawValue) \(vehicleModel.rawValue)"
        }
        return ""
    }
    
    var postTime: String {
        if let dt {
            return "\(Date(timeIntervalSince1970: dt))"
        }
        return ""
    }
    
    ///Affected vehicle years of both Kia's and Hyundai's
    static var affectedVehicleYears: ClosedRange<Int> {
        return 2011...lastAffectedYear
    }
    
    ///The final year vehicles were affetced. Subject to change 🤷🏽‍♂️
    static var lastAffectedYear: Int {
        2021
    }
    
    func verifyVin(input: String) -> Bool {
       return false
    }
    
    func verifyLicensePlate(input: String) -> Bool {
        return false
    }
}

extension [VehicleModel] {
    
    func filter(_ make: VehicleMake, _ year: Int) -> Self {
        self.sorted(by: <).manufacturer(make).year(year)
    }
    
    private func manufacturer(_ make: VehicleMake) -> Self {
        self.filter({$0.make == make})
    }
    
    private func year(_ year: Int) -> Self {
        self.filter({$0.year.contains(year)})
    }
}
