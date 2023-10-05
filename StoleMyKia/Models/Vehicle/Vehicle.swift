//
//  Vehicle.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 5/7/23.
//

import Foundation

///Associated with either the users current vehicle or reported vehicle
struct Vehicle: Codable {
    
    init(year: Int, make: VehicleMake, model: VehicleModel, color: VehicleColor) {
        self.vehicleYear = year
        self.vehicleMake = make
        self.vehicleModel = model
        self.vehicleColor = color
    }
    
    let vehicleYear: Int
    let vehicleMake: VehicleMake
    let vehicleModel: VehicleModel
    let vehicleColor: VehicleColor
    private var licensePlate: Data? = nil
    private var vin: Data? = nil
}

extension Vehicle {
    
    ///This vehicle contains license plate information.
    var hasLicensePlate: Bool {
        licensePlate == nil ? false : true
    }
    
    ///This vehicle contains vin information.
    var hasVin: Bool {
        vin == nil ? false : true
    }
    
    ///Year, make, model, and color of the vehicle
    var details: String {
        "\(vehicleColor.rawValue) \(vehicleYear) \(vehicleMake.rawValue) \(vehicleModel.rawValue)"
    }
    
    ///Remote notification body content
    var vehicleNotificationDetails: String {
        return "\(vehicleColor.rawValue) \(vehicleYear) \(vehicleMake.rawValue) \(vehicleModel.rawValue)"
    }
    
    ///The title of the annotation in the Apple Maps app
    var appleMapsAnnotationTitle: String {
        return "\(vehicleColor.rawValue) \(vehicleYear) \(vehicleMake.rawValue) \(vehicleModel.rawValue)"
    }
    
    mutating func licensePlateString(_ licenseString: String?) throws {
        guard let licenseString else {
            self.licensePlate = nil
            return
        }
        self.licensePlate = try EncryptedData.createEncryption(input: licenseString)
    }
    
    mutating func vinString(_ vinString: String?) throws {
        guard let vinString else {
            self.vin = nil
            return
        }
        self.vin = try EncryptedData.createEncryption(input: vinString)
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
    
    ///The decoded and unwrapped vehicle license plate string. Returns an empty string if not applicable.
    ///Note that if a report was not provided a vehicle with either a vin or license plate string, it cannot be updated.
    var licensePlateString: String {
        guard let licensePlateData = licenseEncryptedData, let licensePlateString = licensePlateData.decode() else {
            return ""
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
