//
//  ReportVehicleMake.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 4/9/23.
//

import Foundation

enum VehicleMake: String, CaseIterable, Codable, Hashable, Identifiable {
    case hyundai  = "Hyundai"
    case kia      = "Kia"
    case dodge    = "Dodge"
    case infiniti = "Infiniti"
    case honda    = "Honda"
    
    var id: Self { self }
}
