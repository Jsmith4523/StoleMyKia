//
//  Report.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/11/23.
//

import Foundation
import UIKit
import MapKit
import SwiftUI

struct Report: Identifiable, Codable, Comparable {

    var id = UUID()
    
    var uid: String?
    let dt: TimeInterval
    let reportType: ReportType
    let vehicle: Vehicle
    var licensePlate: EncryptedData?
    let distinguishable: String
    var imageURL: String?
    let location: Location?
    var updates: [UUID]?
    
    static func == (lhs: Report, rhs: Report) -> Bool {
        return true
    }
    
    static func < (lhs: Report, rhs: Report) -> Bool {
        lhs.dt < rhs.dt
    }
    
    static func > (lhs: Report, rhs: Report) -> Bool {
        lhs.dt > rhs.dt
    }
    
    func encodeForUploading() throws -> Any? {
        try JSONSerialization.createJsonFromObject(self)
    }
}

extension Report {
    
    mutating func setLicensePlate(_ license: String) throws {
        guard !(license.isEmpty) else {
            self.licensePlate = nil
            return
        }
        
        self.licensePlate = try EncryptedData.createEncryption(input: license)
    }
    
    var licensePlateString: String? {
        guard let licensePlate, let licenseString = licensePlate.decode() else {
            return nil
        }
        return licenseString
    }
    
    var type: String {
        self.reportType.rawValue
    }
    
    var hasVehicleImage: Bool {
        guard !(imageURL == nil) else {
            return false
        }
        
        return true
    }
    
    var vehicleDetails: String {
        self.vehicle.details
    }
    
    var postTime: String {
        Date(timeIntervalSince1970: dt).formatted(.dateTime.hour().minute())
    }
    
    var postDate: String {
        Date(timeIntervalSince1970: dt).formatted(.dateTime.month().day().year())
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
        case .carjacked:
            return "Someone was carjacked of their \(self.vehicleDetails) at this location on \(self.postDate). This vehicle is a high risk. If you happen to have seen this vehicle, do not approach. Please contact local authorities and update this report."
        }
    }
    
    func verifyLicensePlate(_ inputLicense: String) -> Bool {
        guard let licensePlateString else {
            return false
        }
        
        return inputLicense == licensePlateString
    }
}

extension [Report] {
    
    
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
        self.filter({$0.verifyLicensePlate(licensePlateString)})
    }
}
