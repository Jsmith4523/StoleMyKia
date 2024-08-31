//
//  ReportVehicleModel.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 4/9/23.
//

import Foundation
import UIKit

//MARK: Vehicles affected from NTSB
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

enum VehicleModel: String, CaseIterable, Codable, Comparable, Hashable, Identifiable {
    
    //MARK: - Hyundai Vehicles
    case accent   = "Accent"
    case elantra  = "Elantra"
    case kona     = "Kona"
    case santaFe  = "Santa Fe"
    case tucson   = "Tucson"
    case veloster = "Veloster"
    case sonata   = "Sonata"
    case venue    = "Venue"
    
    //MARK: - Kia Vehicles
    case forte    = "Forte"
    case rio      = "Rio"
    case optima   = "Optima"
    case soul     = "Soul"
    case sportage = "Sportage"
    case sedona   = "Sedona"
    case sorento  = "Sorento"
    case seltos   = "Seltos"
    case k5       = "K5"
    
    //MARK: - Dodge
    case chargerSXT     = "Charger SXT"
    case chargerGT      = "Charger GT"
    case chargerRT      = "Charger RT"
    case chargerScat    = "Charger Scat Pack"
    case chargerHellCat = "Charger SRT Hellcat"
    case chargerHellCatWideBody = "Charger SRT Hellcat Wide Body"

    case challengerSXT     = "Challenger SXT"
    case challengerGT      = "Challenger GT"
    case challengerRT      = "Challenger RT"
    case challengerRTScat  = "Challenger RT Scat Pack"
    case challengerHellCat = "Challenger SRT Hellcat"
    case challengerHellCatWideBody = "Challenger SRT Hellcat Wide Body"
    
    //MARK: - Infinity
    case g35     = "G35"
    case g37     = "G37"
    case q50     = "Q50"
    case q60     = "Q60"
    case q70     = "Q70"
    
    //MARK: - Honda
    case accord   = "Accord"
    case civic    = "Civic"
    case cr_v     = "CR-V"
    case pilot   = "Pilot"
    case hr_v    = "HR-V"
    case odyssey = "Odyssey"
    
    
    var id: Self { self }
    
    ///Manufacturer
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
        case .tucson:
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
        case .k5:
            return .kia
        case .sedona:
            return .kia
        case .chargerSXT:
            return .dodge
        case .chargerGT:
            return .dodge
        case .chargerRT:
            return .dodge
        case .chargerScat:
            return .dodge
        case .chargerHellCat:
            return .dodge
        case .challengerSXT:
            return .dodge
        case .challengerGT:
            return .dodge
        case .challengerRT:
            return .dodge
        case .challengerRTScat:
            return .dodge
        case .challengerHellCat:
            return .dodge
        case .chargerHellCatWideBody:
            return .dodge
        case .challengerHellCatWideBody:
            return .dodge
        case .g35:
            return .infiniti
        case .g37:
            return .infiniti
        case .q50:
            return .infiniti
        case .q60:
            return .infiniti
        case .q70:
            return .infiniti
        case .accord:
            return .honda
        case .civic:
            return .honda
        case .cr_v:
            return .honda
        case .pilot:
            return .honda
        case .hr_v:
            return .honda
        case .odyssey:
            return .honda
        }
    }
    
    ///The current affected theft year range of a vehicle
    var year: ClosedRange<Int> {
        switch self {
        case .accent:
            return 2011...VehicleModel.lastAffectedYear
        case .elantra:
            return 2011...VehicleModel.lastAffectedYear
        case .kona:
            return 2018...VehicleModel.lastAffectedYear
        case .santaFe:
            return 2011...VehicleModel.lastAffectedYear
        case .tucson:
            return 2011...VehicleModel.lastAffectedYear
        case .veloster:
            return 2011...VehicleModel.lastAffectedYear
        case .sonata:
            return 2011...VehicleModel.lastAffectedYear
        case .venue:
            return 2020...VehicleModel.lastAffectedYear
        case .forte:
            return 2011...VehicleModel.lastAffectedYear
        case .rio:
            return 2011...VehicleModel.lastAffectedYear
        case .optima:
            return 2011...2021
        case .soul:
            return 2011...VehicleModel.lastAffectedYear
        case .sportage:
            return 2011...VehicleModel.lastAffectedYear
        case .sorento:
            return 2011...VehicleModel.lastAffectedYear
        case .seltos:
            return 2019...VehicleModel.lastAffectedYear
        case .k5:
            return 2021...VehicleModel.lastAffectedYear
        case .sedona:
            return 2015...VehicleModel.lastAffectedYear
        case .chargerSXT:
            return 2015...2024
        case .chargerGT:
            return 2015...2024
        case .chargerRT:
            return 2015...2024
        case .chargerScat:
            return 2015...2024
        case .chargerHellCat:
            return 2015...2024
        case .chargerHellCatWideBody:
            return 2021...2024
        case .challengerSXT:
            return 2015...2024
        case .challengerGT:
            return 2015...2024
        case .challengerRT:
            return 2015...2024
        case .challengerRTScat:
            return 2015...2024
        case .challengerHellCat:
            return 2015...2024
        case .challengerHellCatWideBody:
            return 2018...2024
        case .g35:
            return 2003...2024
        case .g37:
            return 2008...2013
        case .q50:
            return 2014...2024
        case .q60:
            return 2017...2024
        case .q70:
            return 2014...2019
        case .accord:
            return 2011...2024
        case .civic:
            return 2011...2024
        case .cr_v:
            return 2011...2024
        case .pilot:
            return 2011...2024
        case .hr_v:
            return 2018...2024
        case .odyssey:
            return 2011...2024
        }
    }
    
    var yearRangeLabel: String {
        return "\(self.year.lowerBound) through \(self.year.upperBound)"
    }
    
    ///This is the final year both Hyundai and Kia vehicles are affected by the anti-theft vulnerability. Subject to change
    static var lastAffectedYear: Int {
        2022
    }
    
    ///This is the affect year ranges of most Kia and Hyundai models
    static var affectedYearRange: ClosedRange<Int> {
        2011...lastAffectedYear
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
    
    func manufacturer(_ make: VehicleMake) -> Self {
        self.filter({$0.make == make}).sorted(by: <)
    }
    
    private func year(_ year: Int) -> Self {
        self.filter({$0.year.contains(year)})
    }
}

