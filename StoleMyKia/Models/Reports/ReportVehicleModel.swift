//
//  ReportVehicleModel.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 4/9/23.
//

import Foundation
import UIKit

//MARK: Vehicles affected based from NTSB
//2015-2021 Hyundai Accent (all body styles)
//2015-2021 Hyundai Elantra (two-door and four-door)
//2015-2021 Hyundai Kona
//2015-2021 Hyundai Santa Fe
//2015-2021 Hyundai Tucson
//2015-2018 Hyundai Veloster
//2015-2021 Kia Forte
//2015-2021 Kia Optima
//2015-2016 Kia Optima Hybrid
//2015-2021 Kia Rio (all body styles)
//2015-2021 Kia Sedona
//2015-2016 Kia Sorento
//2015-2021 Kia Soul
//2015-2021 Kia Sportage

enum VehicleModel: String, CaseIterable, Codable, Comparable {
    
    //MARK: - Hyundai Vehicles
    case accent   = "Accent"
    case elantra  = "Elantra"
    case kona     = "Kona"
    case santaFe  = "Santa Fe"
    case tuscon   = "Tuscon"
    case veloster = "Veloster"
    case sonata   = "Sonata"
    case venue    = "Venue"
    
    //MARK: - Kia Vehicles
    case forte    = "Forte"
    case rio      = "Rio"
    case optima   = "Optima"
    case soul     = "Soul"
    case sportage = "Sportage"
    case sorento  = "Sorento"
    case seltos   = "Seltos"
    
    //Vehicle make (ex: Hyundai Elantra)
    var make: VehicleMake {
        switch self {
            
        case .accent:
            return .hyundai
        case .elantra:
            return .hyundai
        case .kona:
            return .hyundai
        case .santaFe:
            return .hyundai
        case .tuscon:
            return .hyundai
        case .veloster:
            return .hyundai
        case .sonata:
            return .hyundai
        case .venue:
            return .hyundai
        case .forte:
            return .kia
        case .rio:
            return .kia
        case .optima:
            return .kia
        case .soul:
            return .kia
        case .sportage:
            return .kia
        case .sorento:
            return .kia
        case .seltos:
            return .kia
        }
    }
    
    ///The current affected year range of a vehicle. This many change in the future because Hyundai!!!
    var year: ClosedRange<Int> {
        switch self {
        case .accent:
            return 2011...Report.lastAffectedYear
        case .elantra:
            return 2011...Report.lastAffectedYear
        case .kona:
            return 2018...Report.lastAffectedYear
        case .santaFe:
            return 2011...Report.lastAffectedYear
        case .tuscon:
            return 2011...Report.lastAffectedYear
        case .veloster:
            return 2011...Report.lastAffectedYear
        case .sonata:
            return 2011...Report.lastAffectedYear
        case .venue:
            return 2019...Report.lastAffectedYear
        case .forte:
            return 2011...Report.lastAffectedYear
        case .rio:
            return 2011...Report.lastAffectedYear
        case .optima:
            return 2011...Report.lastAffectedYear
        case .soul:
            return 2011...Report.lastAffectedYear
        case .sportage:
            return 2011...Report.lastAffectedYear
        case .sorento:
            return 2011...Report.lastAffectedYear
        case .seltos:
            return 2019...Report.lastAffectedYear
        }
    }
    
    static func < (lhs: VehicleModel, rhs: VehicleModel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    static func > (lhs: VehicleModel, rhs: VehicleModel) -> Bool {
        lhs.rawValue > rhs.rawValue
    }
    
    ///Will return a vehicle to the given arguments if the conditions do not match.
    func matches(make: VehicleMake, year: Int) -> Self {
        if (self.make == make && self.year.contains(year)) {
            return self
        } else if !(self.year.contains(year)) {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            return Self.allCases.filter(make, year).first!
        }
        else {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            return Self.allCases.filter(make, year).first!
        }
    }
}


extension [VehicleModel] {
    
    func filter(_ make: VehicleMake, _ year: Int) -> Self {
        self.sorted(by: <).manufacturer(make).year(year)
    }
    
    private func manufacturer(_ make: VehicleMake) -> Self {
        self.filter({$0.make == make})
    }
    
    private func year(_ year: Int) -> Self {
        self.filter({$0.year.contains(year)})
    }
}

