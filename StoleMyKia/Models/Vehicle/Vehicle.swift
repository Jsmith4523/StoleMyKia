//
//  Vehicle.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 5/7/23.
//

import Foundation

///Associated with either the users current vehicle or reported vehicle
struct Vehicle: Codable {
    let vehicleYear: Int
    let vehicleMake: VehicleMake
    let vehicleColor: VehicleColor
    let vehicleModel: VehicleModel
    var licensePlate: EncryptedData?
    var vin: EncryptedData?
}

extension Vehicle {
    
    ///Year, make, model, and color of the vehicle
    var details: String {
        "\(vehicleYear) \(vehicleMake.rawValue) \(vehicleModel.rawValue) (\(vehicleColor.rawValue))"
    }
    
    ///Notification body cotent
    var vehicleNotificationDetails: String {
        "\(vehicleColor) \(vehicleYear) \(vehicleMake.rawValue) \(vehicleModel.rawValue) (\(licensePlateString))"
    }
    
    ///The decoded and unwrapped vehicle license plate string. Returns an empty string if not applicable
    ///Note that if a report was not provided a vehicle with either a vin or license plate string, it cannot be updated.
    var licensePlateString: String {
        guard let licensePlate = licensePlate, let licenseString = licensePlate.decode() else {
            return ""
        }
        return "License no. \(licenseString)"
    }
}
