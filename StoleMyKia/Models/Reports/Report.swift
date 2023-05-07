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

struct Report: Identifiable, Codable, Comparable {

    var id = UUID()
    
    var uid: String?
    let dt: TimeInterval?
    let reportType: ReportType
    var status: ReportStatus = .open
    let vehicle: Vehicle
    let licensePlate: EncryptedData?
    let vin: EncryptedData?
    let distinguishable: String
    var imageURL: String?
    var isFound: Bool?
    let location: Location?
    var updates: [Report]?
    
    enum ReportStatus: Codable, Hashable {
        case open
        case closed
    }
    
    static func == (lhs: Report, rhs: Report) -> Bool {
        return true
    }
    
    static func < (lhs: Report, rhs: Report) -> Bool {
        if let lhsTime = lhs.dt, let rhsTime = rhs.dt {
            return lhsTime < rhsTime
        }
        return false
    }
    
    static func > (lhs: Report, rhs: Report) -> Bool {
        if let lhsTime = lhs.dt, let rhsTime = rhs.dt {
            return lhsTime > rhsTime
        }
        return false
    }
}

extension Location {
    var coordinates: CLLocationCoordinate2D? {
        if let lat, let lon {
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        return nil
    }
}

extension Report.ReportStatus {
    var label: some View {
        ZStack {
            switch self {
            case .open:
                HStack {
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundColor(.green)
                    Text("Open")
                        .font(.system(size: 17))
                        .foregroundColor(.gray)
                }
            case .closed:
                HStack {
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundColor(.red)
                    Text("Closed")
                        .font(.system(size: 17))
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

extension Report {
    
    var type: String {
        self.reportType.rawValue
    }
    
    var vehicleDetails: String {
        
        let vehicleYear = self.vehicle.vehicleYear
        let vehicleMake = self.vehicle.vehicleMake
        let vehicleModel = self.vehicle.vehicleModel
        let vehicleColor = self.vehicle.vehicleColor
        
        return "\(vehicleYear) \(vehicleMake.rawValue) \(vehicleModel.rawValue) (\(vehicleColor.rawValue))"
    }
    
    var reportUpdates: [Report] {
        if let updates {
            return updates
        }
        return [Report]()
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
        return true
    }
}

extension [Report] {
    
    ///This method should be used for adding update annotation on the map
    func updates() -> [Report] {
        self.flatMap{$0.updates?.compactMap({$0}) ?? []}
    }
    
    mutating func removeReport(_ deletedReport: Report) {
        self.removeAll { report in
            deletedReport.id == report.id
        }
    }
    
    mutating func including(with reports: [Report]) {
        let currentIds = Set(self.map({$0.id}))
        let filterReports = reports.filter {!currentIds.contains($0.id)}
        
        self.append(contentsOf: filterReports)
    }
    
    func matchesLicensePlate(_ licensePlateString: String) -> [Report] {
        self.filter({$0.verifyLicensePlate(input: licensePlateString)})
    }
}
