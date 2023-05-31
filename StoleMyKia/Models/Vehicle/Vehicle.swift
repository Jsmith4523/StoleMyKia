//
//  Vehicle.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 5/7/23.
//

import Foundation


struct Vehicle: Codable {
    let vehicleYear: Int
    let vehicleMake: VehicleMake
    let vehicleColor: VehicleColor
    let vehicleModel: VehicleModel
}

extension Vehicle {
    
    
    var details: String {
        "\(vehicleYear) \(vehicleMake.rawValue) \(vehicleModel.rawValue) (\(vehicleColor.rawValue))"
    }
}
