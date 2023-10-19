//
//  ReportType.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 4/9/23.
//

import Foundation
import UIKit

enum ReportType: String, CaseIterable, Hashable, Identifiable, Codable, Comparable {
    
    static let updateCases: [Self] = [.found, .witnessed, .incident, .located]
    
    case attempt     = "Attempt"
    case carjacked   = "Car Jacking"
    case stolen      = "Stolen"
    case found       = "Recovered"
    case witnessed   = "Witnessed"
    case located     = "Located"
    case breakIn     = "Break-In"
    case incident    = "Incident"
    
    ///Raw value
    var id: String {
        return self.rawValue
    }
    
    var annotationImage: String {
        switch self {
        case .stolen:
            return "car.fill"
        case .found:
            return "checkmark.shield.fill"
        case .witnessed:
            return "eye.fill"
        case .located:
            return "mappin"
        case .carjacked:
            return "sos"
        case .attempt:
            return "exclamationmark.triangle"
        case .breakIn:
            return "screwdriver.fill"
        case .incident:
            return "figure.run"
        }
    }
    
    var symbol: String {
        self.annotationImage
    }
    
    ///The description of a new report type
    var description: String {
        switch self {
        case .stolen:
            return "Your vehicle was stolen and you are reporting it."
        case .found:
            return "You safely located and/or recovered a vehicle."
        case .witnessed:
            return "You witnessed a vehicle being stolen."
        case .located:
            return "You located this vehicle."
        case .carjacked:
            return "Your vehicle was stolen by force."
        case .incident:
            return "An incident occurred with a vehicle."
        case .attempt:
            return "Someone attempted to steal this vehicle."
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
            return .red
        case .located:
            return .purple
        case .carjacked:
            return .red
        case .attempt:
            return .orange
        case .breakIn:
            return .systemOrange
        case .incident:
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
        case .witnessed:
            return false
        case .located:
            return false
        case .attempt:
            return false
        case .breakIn:
            return false
        case .incident:
            return false
        }
    }
    
    static func < (lhs: ReportType, rhs: ReportType) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    static func > (lhs: ReportType, rhs: ReportType) -> Bool {
        lhs.rawValue > rhs.rawValue
    }
}
