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
    var address: String? = nil
    var name: String? =  nil
    let lat: Double
    let lon: Double
}

extension Location {
    
    var coordinates: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    var region: MKCoordinateRegion {
        MKCoordinateRegion(center: self.coordinates, span: .init(latitudeDelta: 0.002, longitudeDelta: 0.002))
    }
    
    var hasAddress: Bool {
        guard let address else {
            return false
        }
        
        guard !(address.isEmpty) else {
            return false
        }
        
        return true
    }
    
    var hasName: Bool {
        guard let name else {
            return false
        }
        
        guard !(name.isEmpty) else {
            return false
        }
        
        return true
    }
}

extension Location? {
    
    func isNil() -> Bool {
        self == nil
    }
}
