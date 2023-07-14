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
    private(set) var role: ReportRole!
    
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
        case .witnessed:
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
    
    /// Set this report.role as 'original'
    /// - Returns: self
    func setAsOriginal() -> Self {
        var report = self
        report.role = .original(report.id)
        return report
    }
    
    /// Set this report as 'update'
    /// - Parameter parentId: The parent report UUID.
    /// - Returns: self
    func setAsUpdate(_ parentId: UUID) -> Self {
        var report = self
        report.role = .update(parentId)
        return report
    }
    
    mutating func setLicensePlate(_ license: String) throws {
        guard !(license.isEmpty) else {
            try self.vehicle.licensePlateString(nil)
            return
        }
        
       try self.vehicle.licensePlateString(license)
    }
    
    var type: String {
        self.reportType.rawValue
    }
    
    ///Absolute file path to this image associated with this report in Google Storage
    var vehicleImagePath: String {
        return "Reports/Vehicles/\(path)"
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
            .init(dt: Date.now.epoch, reportType: .breakIn, vehicle: .init(year: 2017, make: .hyundai, model: .elantra, color: .black), distinguishableDetails: "We regret to inform you that your 2017 Hyundai Elantra, with the license plate number ABC1234, has been reported stolen. This silver-colored vehicle has a distinct mark on the rear bumper, resembling a small scratch on the left corner. Please contact the local authorities immediately and provide them with the above details for further investigation. Your cooperation is highly appreciated in the recovery of your vehicle. Stay vigilant and let's work together to retrieve your stolen Hyundai Elantra", imageURL: "https://wtop.com/wp-content/uploads/2016/07/elantra3-1672x1254.jpg", location: .init(address: "801 K St, NW DC", name: "Apple Carniege Library", lat: 40.72781, lon: -74.00743)).setAsUpdate(UUID()),
            .init(dt: Date.now.epoch, reportType: .stolen, vehicle: .init(year: 2019, make: .kia, model: .soul, color: .green), distinguishableDetails: "My Kia Soul was stolen outside of Eddie's Bar in Times Square MD. Really hoping someone can help me locate it. Thanks!", imageURL: "https://i.ytimg.com/vi/dhQkYX5kmes/maxresdefault.jpg", location: .init(address: "801 K St, NW DC", name: "Eddie's bar", lat: 40.72781, lon: -74.00743)).setAsUpdate(UUID()),
            .init(dt: Date.now.epoch, reportType: .found, vehicle: .init(year: 2018, make: .hyundai, model: .sonata, color: .brown), distinguishableDetails: "Found this Hyundai Sonata outside of my home this morning. Not sure whose car this is, but it's here! Please contact me for more info", location: .init(address: "801 K St, NW DC", lat: 40.72781, lon: -74.00743)).setAsOriginal()
        ]
    }
}
