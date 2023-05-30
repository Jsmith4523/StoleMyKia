//
//  Location.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 5/7/23.
//

import Foundation
import MapKit

///Object relating to MKLocalSearch for a report
struct Location: Codable, Identifiable, Hashable {
    var id = UUID()
    let address: String?
    let name: String?
    let lat: Double?
    let lon: Double?
}

extension Location {
    var coordinates: CLLocationCoordinate2D? {
        if let lat, let lon {
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        return nil
    }
}

extension Location? {
    
    func isNil() -> Bool {
        self == nil
    }
}
