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

public struct Report: Identifiable, Codable, Comparable {
    
    static let descriptionCharacterLimit = 500
    
    ///init with requried details
    init(uid: String, type: ReportType, Vehicle: Vehicle, details: String, location: Location, discloseLocation: Bool) {
        let id = UUID()
        self.id = id
        self.dt = Date.now.epoch
        self.uid = uid
        self.reportType = type
        self.vehicle = Vehicle
        self.distinguishableDetails = details
        self.location = location
        self.role = .original(id)
        self.discloseLocation = discloseLocation
    }
    
    ///Init with required detail and optional vehicle image url.
    init(uid: String, type: ReportType, Vehicle: Vehicle, vehicleImageUrl: String?, details: String, location: Location, discloseLocation: Bool) {
        let id = UUID()
        self.id = id
        self.dt = Date.now.epoch
        self.uid = uid
        self.reportType = type
        self.vehicle = Vehicle
        self.imageURL = vehicleImageUrl
        self.distinguishableDetails = details
        self.location = location
        self.role = .original(id)
        self.discloseLocation = discloseLocation
    }

    public var id: UUID
    ///The logged in Firebase Auth users uid
    let uid: String
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
    let discloseLocation: Bool
    ///The role of this report
    var role: ReportRole
    ///On the client side, the property is immutable.
    ///On the admin side, this property is mutable if the report is determined false
    var isFalseReport: Bool = false
    ///The UUID string of the update object if applicable.
    ///This is useful when wanting to delete a report if it's an update.
    ///Firebase functions will handle the rest after this report has been deleted.
    var updateId: String?
    
    public static func == (lhs: Report, rhs: Report) -> Bool {
        return true
    }
    
    public static func < (lhs: Report, rhs: Report) -> Bool {
        lhs.dt < rhs.dt
    }
    
    public static func > (lhs: Report, rhs: Report) -> Bool {
        lhs.dt > rhs.dt
    }
    
    func encodeForUploading() throws -> Any? {
        try JSONSerialization.createJsonFromObject(self)
    }
    
    ///The path a report will be saved to in Google Firestore.
    ///This further helps the user fetch for reports depending on thier filter selection.
    var path: String {
        
        let idString = id.uuidString
        let reportTypeRawValue = self.reportType.rawValue
        
        switch self.reportType {
        case .stolen:
            return "\(reportTypeRawValue)/\(idString)"
        case .found:
            return "\(reportTypeRawValue)/\(idString)"
        case .witnessed:
            return "\(reportTypeRawValue)/\(idString)"
        case .located:
            return "\(reportTypeRawValue)/\(idString)"
        case .carjacked:
            return "\(reportTypeRawValue)/\(idString)"
        case .attempt:
            return "\(reportTypeRawValue)/\(idString)"
        case .breakIn:
            return "\(reportTypeRawValue)/\(idString)"
        case .incident:
            return "\(reportTypeRawValue)/\(idString)"
        }
    }
}

extension Report {
    
    private func setAsOriginal() -> ReportRole {
        return .original(self.id)
    }
    
    /// Set this report as 'update'
    /// - Parameter parentId: The parent report UUID.
    /// - Returns: self
    mutating func setAsUpdate(_ parentId: UUID) {
        self.role = .update(parentId)
    }
    
    mutating func setLicensePlate(_ license: String) throws {
        guard !(license.isEmpty) else {
            try self.vehicle.licensePlateString(nil)
            return
        }
        
       try self.vehicle.licensePlateString(license)
    }
    
    var associatedImage: Image {
        if self.isFalseReport {
            return Image.falseReportIcon
        } else if self.discloseLocation {
            return Image.disclosedLocationIcon
        } else {
            return Image(systemName: self.reportType.annotationImage)
        }
    }
    
    var type: String {
        self.reportType.rawValue
    }
    
    ///The Storage path to the vehicle's image
    var vehicleImagePath: String? {
        guard !(imageURL == nil) else {
            return nil
        }
        return self.path
    }
    
    var appleMapsAnnotationTitle: String {
        "\(type) \(self.vehicle.appleMapsAnnotationTitle)"
    }
    
    var deletionBodyText: String {
        if self.role.isAnUpdate {
            return "When deleting this report, it will be removed as an update from the initial report. Are you sure you want to delete?"
        } else {
            return "When deleting this report, any updates made will not be deleted. Are you sure you want to delete?"
        }
    }
        
    var hasVehicleImage: Bool {
        guard !(imageURL == nil) else {
            return false
        }
        
        return true
    }
    
    var hasLicensePlate: Bool {
        self.vehicle.hasLicensePlate
    }
    
    var hasVin: Bool {
        self.vehicle.hasVin
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
    
    func timeSinceString() -> String {
        return ApplicationFormats.timeAgoFormat(self.dt)
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
        var falseReport: Report = .init(uid: "", type: .stolen, Vehicle: .init(year: 2017, make: .hyundai, model: .elantra, color: .red), vehicleImageUrl: "https://vehicle-images.dealerinspire.com/b181-110004081/thumbnails/large/5NPD74LF3LH542186/de26ac0d8c1e8517ff3223db441dee38.jpg", details: "My 2017 Hyundai Elantra was stolen outside of my home around 3AM last night. I am unsure where the vehicle is and I am in dire need for help locating it. It has a couple of dents on the driver side door, three stickers on the trunk, and has a matte black spoiler.PLEASE!!! I really need some help locating it. God bless 🙏🏽🙏🏽🙏🏽🙏🏽🙏🏽🙏🏽🙏🏽🙏🏽", location: .init(address: "123 Fun Street", name: "McDonald's", lat: 0, lon: 0), discloseLocation: true)
        falseReport.isFalseReport = true
        return [
            falseReport,
            .init(uid: "", type: .found, Vehicle: .init(year: 2021, make: .kia, model: .forte, color: .red), details: "", location: .init(coordinates: .init()), discloseLocation: false),
            .init(uid: "", type: .breakIn, Vehicle: .init(year: 2013, make: .hyundai, model: .elantra, color: .orange), details: "", location: .init(coordinates: .init()), discloseLocation: false)
        ]
    }
}
