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
    let vehicleModel: VehicleModel
    let vehicleColor: VehicleColor
    var licensePlate: Data?
    var vin: Data?
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
    
    private var licenseEncryptedData: EncryptedData? {
        do {
            guard let licensePlate else {
                return nil
            }
            return try JSONDecoder().decode(EncryptedData.self, from: licensePlate)
        } catch {
            return nil
        }
    }
    
    private var vinEncryptedData: EncryptedData? {
        do {
            guard let vin else {
                return nil
            }
            return try JSONDecoder().decode(EncryptedData.self, from: vin)
        } catch {
            return nil
        }
    }
    
    ///The decoded and unwrapped vehicle license plate string. Returns an empty string if not applicable
    ///Note that if a report was not provided a vehicle with either a vin or license plate string, it cannot be updated.
    var licensePlateString: String {
        guard let licensePlateData = licenseEncryptedData, let licensePlateString = licensePlateData.decode() else {
            return "1EP1757"
        }
        return licensePlateString.uppercased()
    }
    
    
    var vinString: String {
        guard let vinData = vinEncryptedData, let vinString = vinData.decode() else {
            return ""
        }
        
        return vinString.uppercased()
    }
}
