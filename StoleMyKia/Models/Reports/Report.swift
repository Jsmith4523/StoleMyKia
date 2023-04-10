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
import SwiftUI


struct Report: Identifiable, Codable {
    var id = UUID()
    
    var uid: String?
    let dt: TimeInterval?
    let reportType: ReportType
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
        self.reportType.rawValue
    }
    
    var vehicleDetails: String {
        if let vehicleYear, let vehicleMake, let vehicleModel, let vehicleColor {
            return "\(vehicleYear) \(vehicleMake.rawValue) \(vehicleModel.rawValue) (\(vehicleColor.rawValue))"
        }
        return ""
    }
    
    var postTime: String {
        if let dt {
            return "\(Date(timeIntervalSince1970: dt).formatted(.dateTime.hour().minute()))"
        }
        return ""
    }
    
    var postDate: String {
        if let dt {
            return "\(Date(timeIntervalSince1970: dt).formatted(.dateTime.month().day().year()))"
        }
        return ""
    }
    
    var details: String {
        switch self.reportType {
        case .found:
            return "Someone has found this vehicle at this location on \(self.postDate) at \(self.postTime). If this is your vehicle, please inform local authorities of the location and do not attempt to visit unless told by authorities."
        case .stolen:
            return "A \(self.vehicleDetails) has been reported stolen on \(self.postDate) at \(self.postTime). If you happen to have seen this vehicle, please contact local authorities and update this report."
        case .spotted:
            return "Someone has spotted this \(self.vehicleDetails) on \(self.postDate) at \(self.postTime). If you happen to have seen this vehicle, please contact local authorities and update this report."
        case .withnessed:
            return "Someone witnessed a \(self.vehicleDetails) being stolen at this location on \(self.postDate) at \(self.postTime). If you happen to have seen this vehicle, please contact local authorities and update this report."
        }
    }
    
    ///Affected vehicle years of both Kia's and Hyundai's. This is set for most vehicles.
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
