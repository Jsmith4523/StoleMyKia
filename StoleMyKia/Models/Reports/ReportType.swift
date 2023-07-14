//
//  ReportType.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 4/9/23.
//

import Foundation
import UIKit

enum ReportType: String, CaseIterable, Hashable, Identifiable, Codable {
    
    case attempt     = "Attempt"
    case carjacked   = "Car Jacking"
    case stolen      = "Stolen"
    case found       = "Found"
    case witnessed  = "Witnessed"
    case located     = "Located"
    case breakIn     = "Break-In"
    
    ///Raw value
    var id: String {
        return self.rawValue
    }
    
    var annotationImage: String {
        switch self {
        case .stolen:
            return "car.2.fill"
        case .found:
            return "checkmark.shield.fill"
        case .witnessed:
            return "person.crop.circle.badge.exclamationmark.fill"
        case .located:
            return "eye.fill"
        case .carjacked:
            return "light.beacon.max.fill"
        case .attempt:
            return "exclamation"
        case .breakIn:
            return "screwdriver.fill"
        }
    }
    
    ///The description of a new report type
    var description: String {
        switch self {
        case .stolen:
            return "Your vehicle was stolen and you are reporting it."
        case .found:
            return "You safely found a vehicle."
        case .witnessed:
            return "You witnessed a vehicle being stolen."
        case .located:
            return "You located this vehicle."
        case .carjacked:
            return "Your vehicle was stolen by force."
        case .attempt:
            return "Someone attempted to steal this vehicle"
        case .breakIn:
            return "Someone broke into this vehicle."
        }
    }
    
    ///The map annotation color (or just associated color with this report type)
    var annotationColor: UIColor {
        switch self {
        case .stolen:
            return .red
        case .found:
            return .purple
        case .witnessed:
            return .systemBlue
        case .located:
            return .purple
        case .carjacked:
            return .red
        case .attempt:
            return .orange
        case .breakIn:
            return .orange
        }
    }
    
    
    var allowsForUpdates: Bool {
        switch self {
        case .carjacked:
            return true
        case .stolen:
            return true
        case .found:
            return true
        case .witnessed:
            return true
        case .located:
            return false
        case .attempt:
            return false
        case .breakIn:
            return false
        }
    }
    
    ///When a user is creating a report type that may require additonal information such as the vehicle license plate.
    var requiresLicensePlateInformation: Bool {
        switch self {
        case .carjacked:
            return true
        case .stolen:
            return true
        case .found:
            return false
        case .witnessed:
            return false
        case .located:
            return false
        case .attempt:
            return false
        case .breakIn:
            return false
        }
    }
    
    ///Disables the License Plate and Vin information section.
    var disableLicenseAndVinInformation: Bool {
        switch self {
        case .attempt:
            return true
        case .carjacked:
            return false
        case .stolen:
            return false
        case .found:
            return false
        case .witnessed:
            return false
        case .located:
            return false
        case .breakIn:
            return true
        }
    }
    
    func generateNotificationBody(for vehicle: Vehicle) -> String {
        let vehicleDetails = vehicle.vehicleNotificationDetails
                
        switch self {
            
        case .carjacked:
            return "A \(vehicleDetails) has been reported in a carjacking. Do not approach the vehicle and call local authorities immediately once located."
        case .stolen:
            return "A \(vehicleDetails) has been reported stolen."
        case .found:
            return "A \(vehicleDetails) has been reported safely found."
        case .witnessed:
            return "Someone witnessed a \(vehicleDetails) being stolen."
        case .located:
            return "A \(vehicleDetails) has been located."
        case .attempt:
            return "Someone attempted to steal a \(vehicleDetails)."
        case .breakIn:
            return "A report of a break-in occurred on a \(vehicleDetails) "
        }
    }
    
    ///Enums avaliable when creating a NEW report.
    static var reports: [ReportType] {
        [.carjacked, .stolen, .witnessed, .found, .attempt, .breakIn]
    }
    
    ///Enums avaliable when updating a report
    static var update: [ReportType] {
        [.carjacked, .stolen, .witnessed, .found, .located]
    }
}
