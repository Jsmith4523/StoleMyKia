//
//  ReportVehicleColor.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 4/9/23.
//

import Foundation
import SwiftUI

enum VehicleColor: String, CaseIterable, Codable, Hashable, Identifiable, Comparable {
    
    case red       = "Red"
    case yellow    = "Yellow"
    case white     = "White"
    case green     = "Green"
    case blue      = "Blue"
    case orange    = "Orange"
    case silver    = "Silver"
    case black     = "Black"
    case gold      = "Gold"
    case gray      = "Gray"
    case lightGray = "Light Gray"
    case brown     = "Brown"
    case violet    = "Violet"
    
    var id: Self { self }
    
    var color: Color {
        switch self {
        case .red:
            return .red
        case .yellow:
            return .yellow
        case .white:
            return .white
        case .green:
            return .green
        case .blue:
            return .blue
        case .orange:
            return .orange
        case .silver:
            return Color("silver")
        case .black:
            return .black
        case .gold:
            return Color("gold")
        case .gray:
            return .gray
        case .lightGray:
            return Color(uiColor: .lightGray)
        case .brown:
            return .brown
        case .violet:
            return .brand
        }
    }
    
    static func < (lhs: VehicleColor, rhs: VehicleColor) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
