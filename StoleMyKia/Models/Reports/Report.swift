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
    let distinguishable: String
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
    
    ///The path a report will be saved to in Google Firebase.
    ///This further helps the user fetch for reports depending on thier filter selection.
    var path: String {
        
        let idString = id.uuidString
        
        switch self.reportType {
        case .stolen:
            return "/Stolen/\(idString)"
        case .found:
            return "/Found/\(idString)"
        case .withnessed:
            return "/Witnessed/\(idString)"
        case .spotted:
            return "/Spotted/\(idString)"
        case .carjacked:
            return "/Carjacked/\(idString)"
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
        guard !(inputLicense.isEmpty), !(vehicle.licensePlateString.isEmpty) else {
            return false
        }
        
        return (inputLicense == vehicle.licensePlateString || vehicle.licensePlateString.contains(inputLicense))
    }
    
    func verifyDescription(_ input: String) -> Bool {
        guard !(input.isEmpty), !(details.isEmpty) else {
            return false
        }
        
        return (input == details || details.contains(input))
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
        
         return [Report]()
//        return [Report(uid: "123", dt: Date.now.epoch, reportType: .stolen, vehicle: .init(vehicleYear: 2011, vehicleMake: .hyundai, vehicleColor: .gold, vehicleModel: .elantra), distinguishable: "", location: .init(address: "1105 South Drive, Oxon Hill, Maryland",name: "92NY",lat: 40.78245, lon: -73.95608), role: .original),
//                Report(uid: "123", dt: Date.now.epoch, reportType: .withnessed, vehicle: .init(vehicleYear: 2011, vehicleMake: .hyundai, vehicleColor: .gold, vehicleModel: .elantra), distinguishable: "", location: .init(address: "1105 South Drive, Oxon Hill, Maryland",name: "92NY",lat: 45.4432, lon: -54.432), role: .update),
//                Report(uid: "123", dt: Date.now.epoch, reportType: .found, vehicle: .init(vehicleYear: 2011, vehicleMake: .hyundai, vehicleColor: .gold, vehicleModel: .elantra), distinguishable: "", imageURL: "https://static01.nyt.com/images/2011/07/10/automobiles/WHEE/WHEE-articleLarge.jpg?quality=75&auto=webp&disable=upscale", location: .init(address: "1105 South Drive, Oxon Hill, Maryland",name: "92NY",lat: 45.4432, lon: -54.432), role: .original),
//                Report(uid: "123", dt: Date.now.epoch, reportType: .carjacked, vehicle: .init(vehicleYear: 2011, vehicleMake: .hyundai, vehicleColor: .gold, vehicleModel: .elantra), distinguishable: "", location: .init(address: "1105 South Drive, Oxon Hill, Maryland",name: "92NY",lat: 45.4432, lon: -54.432), role: .original),
//                Report(uid: "123", dt: Date.now.epoch, reportType: .spotted, vehicle: .init(vehicleYear: 2011, vehicleMake: .hyundai, vehicleColor: .gold, vehicleModel: .elantra), distinguishable: "", imageURL: "https://automanager.blob.core.windows.net/wmphotos/012928/b98b458d9854eb4db5b9d4d637b5cbf5/b21f0c7166_800.jpg", location: .init(address: "1105 South Drive, Oxon Hill, Maryland",name: "92NY",lat: 45.4432, lon: -54.432), role: .update)
//        ]
    }
}
