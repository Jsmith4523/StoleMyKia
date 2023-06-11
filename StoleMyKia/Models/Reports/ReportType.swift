//
//  ReportType.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 4/9/23.
//

import Foundation
import UIKit

enum ReportType: String, CaseIterable, Hashable, Identifiable, Codable {
    
    case carjacked   = "Car Jacking"
    case stolen      = "Stolen"
    case found       = "Found"
    case withnessed  = "Witnessed"
    case spotted     = "Spotted"
    
    ///Raw value
    var id: String {
        return self.rawValue
    }
    
    var annotationImage: String {
        switch self {
        case .stolen:
            return "car.2.fill"
        case .found:
            return "checkmark.shield"
        case .withnessed:
            return "person.crop.circle.badge.exclamationmark.fill"
        case .spotted:
            return "eye.fill"
        case .carjacked:
            return "light.beacon.max.fill"
        }
    }
    
    ///The description of a new report type
    var description: String {
        switch self {
        case .stolen:
            return "Your vehicle was stolen and you are reporting it."
        case .found:
            return "You've found a vehicle that was stolen."
        case .withnessed:
            return "You withnessed a vehicle being stolen."
        case .spotted:
            return "eyeglasses"
        case .carjacked:
            return "Your vehicle was stolen by force."
        }
    }
    
    ///The map annotation color (or just associated color with this report type)
    var annotationColor: UIColor {
        switch self {
        case .stolen:
            return .red
        case .found:
            return .purple
        case .withnessed:
            return .systemBlue
        case .spotted:
            return UIColor(.spottedGreen)
        case .carjacked:
            return .red
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
        case .withnessed:
            return false
        case .spotted:
            return false
        }
    }
    
    func generateNotificationBody(for vehicle: Vehicle) -> String {
        let notificationDetails = vehicle.vehicleNotificationDetails
        
        switch self {
            
        case .carjacked:
            return "A \(notificationDetails) has been carjacked. Do not approach the vehicle and call local authorities immediately once spotted."
        case .stolen:
            return "A \(notificationDetails) has been stolen."
        case .found:
            return "A \(notificationDetails) has been found."
        case .withnessed:
            return "Someone withness this \(notificationDetails) being stolen."
        case .spotted:
            return "A \(notificationDetails) has been spotted by someone"
        }
    }
    
    ///Enums avaliable when creating a NEW report.
    static var reports: [ReportType] {
        [.carjacked, .stolen, .withnessed, .found]
    }
    
    ///Enums avaliable when updating a report
    static var update: [ReportType] {
        [.found, .spotted]
    }
}
