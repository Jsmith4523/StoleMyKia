//
//  Location.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 5/7/23.
//

import Foundation

///Object relating to MKLocalSearch for a report
struct Location: Codable, Identifiable, Hashable {
    var id = UUID()
    let address: String?
    let name: String?
    let lat: Double?
    let lon: Double?
}

extension Location? {
    
    func isNil() -> Bool {
        self == nil
    }
}
