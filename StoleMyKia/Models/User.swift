//
//  User.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/7/23.
//

import Foundation

struct AppUser: Codable {
    
    static let statusKey = Self.CodingKeys.status.rawValue
    
    let uid: String
    let status: Status
    let phoneNumber: String
    ///Cooldown for making reports and updates
    var cooldown: TimeInterval? = nil
    
    enum Status: String, Codable {
        case disabled = "Disabled"
        case banned   = "Banned"
        case active   = "Active"
        case newUser  = "New User"
        
        var description: String {
            switch self {
            case .disabled:
                return "Your account has been disabled. Please contact support."
            case .banned:
                return "Your account has been banned. Please contact support for more information."
            default:
                return ""
            }
        }
    }
        
    enum CodingKeys: String, CodingKey {
        case uid = "uid"
        case status = "status"
        case phoneNumber = "phone_number"
        case cooldown = "cooldown"
    }
    
    func encodeForUpload() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        let value = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        return value
    }
}
