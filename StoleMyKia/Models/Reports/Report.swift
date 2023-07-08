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
    
    ///The logged in Firebase Auth users uid
    var uid: String?
    ///The time of this report in epoch
    let dt: TimeInterval
    ///The type of report
    let reportType: ReportType
    ///The vehicle with this report (ex: 2017 Hyundai Elantra (Gray))
    var vehicle: Vehicle
    ///The uniqueness of the vehicle
    let distinguishableDetails: String
    ///Firebase Storage url
    var imageURL: String?
    ///The location of this report
    let location: Location
    ///The role of this report
    var role: ReportRole
    ///The parent report uuid if this report is an update
    
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
    
    ///The path a report will be saved to in Google Firestore.
    ///This further helps the user fetch for reports depending on thier filter selection.
    var path: String {
        
        let idString = id.uuidString
        
        switch self.reportType {
        case .stolen:
            return "Stolen/\(idString)"
        case .found:
            return "Found/\(idString)"
        case .withnessed:
            return "Witnessed/\(idString)"
        case .located:
            return "Located/\(idString)"
        case .carjacked:
            return "Carjacked/\(idString)"
        case .attempt:
            return "Attempt/\(idString)"
        case .breakIn:
            return "BreakIn/\(idString)"
        }
    }
}

extension Report {
    
    mutating func setLicensePlate(_ license: String) throws {
        guard !(license.isEmpty) else {
            self.vehicle.licensePlate = nil
            return
        }
        
        self.vehicle.licensePlate = try EncryptedData.createEncryption(input: license)
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
    
    func verifyLicensePlate(_ inputLicense: String) -> Bool {
        guard !(inputLicense.isEmpty), !(vehicle.licensePlateString.isEmpty) else {
            return false
        }
        
        return (inputLicense == vehicle.licensePlateString || vehicle.licensePlateString.contains(inputLicense))
    }
    
    func verifyDescription(_ input: String) -> Bool {
        guard !(input.isEmpty), !(distinguishableDetails.isEmpty) else {
            return false
        }
        
        return (input == distinguishableDetails || distinguishableDetails.contains(input))
    }
    
    func vehicleImage(completion: @escaping (UIImage?)->Void) {
        ImageCache.shared.getImage(self.imageURL) { image in
            completion(image)
        }
    }
    
    func matches(year: Int?,
                 type: ReportType?,
                 make: VehicleMake?,
                 model: VehicleModel?,
                 color: VehicleColor?,
                 input: String
    ) -> Bool {
        (self.vehicle.vehicleYear == year || self.reportType == reportType || self.vehicle.vehicleMake == make || self.vehicle.vehicleModel == model || self.verifyLicensePlate(input) || self.verifyDescription(input))
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
    
    static func testReports() -> [Report] {
        return [
            .init(dt: Date.now.epoch, reportType: .stolen, vehicle: .init(vehicleYear: 2017, vehicleMake: .hyundai, vehicleModel: .elantra, vehicleColor: .red), distinguishableDetails: "", location: .init(lat: 40.72781, lon: -74.00743), role: .original)
        ]
    }
}
