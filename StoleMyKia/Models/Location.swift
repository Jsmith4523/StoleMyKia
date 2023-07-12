//
//  Location.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 5/7/23.
//

import Foundation
import MapKit

///Object relating to MKLocalSearch for a report
struct Location: Codable, Identifiable, Hashable, Comparable {
    var id = UUID()
    var address: String? = nil
    var name: String? =  nil
    let lat: Double
    let lon: Double
}

extension Location {
    
    ///Filtering distance of locations when the users is search for nearby locations.
    ///The distance is 1/2 mile from the users current location to prevent potential trolling (I'm looking at you, Kia Boys).
    static var nearbyLocationDistance: Double {
        0.5
    }
    
    private static func userLocation() -> CLLocation? {
        guard let userLocation = CLLocationManager.shared.location else { return nil}
        return userLocation
    }
    
    static func > (lhs: Location, rhs: Location) -> Bool {
        guard let userLocation = userLocation() else { return false}
        return calculateDistanceInMiles(from: lhs.location, to: userLocation) > calculateDistanceInMiles(from: rhs.location, to: userLocation)
    }
    
    static func < (lhs: Location, rhs: Location) -> Bool {
        guard let userLocation = userLocation() else { return false}
        return calculateDistanceInMiles(from: lhs.location, to: userLocation) < calculateDistanceInMiles(from: rhs.location, to: userLocation)
    }
    
    ///Location distance from the user in miles.
    var distanceFromUser: String {
        guard let userLocation = Self.userLocation() else { return "NA"}
        return userLocation.calculateDistanceInMilesString(to: self.location)
    }
        
    private var location: CLLocation {
        CLLocation(latitude: lat, longitude: lon)
    }

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

extension Location {
    
    static func calculateDistanceInMiles(from location: CLLocation, to destinationLocation: CLLocation) -> CLLocationDistance {
        let meters = location.distance(from: destinationLocation)
        let miles = meters * 0.000621371 // Convert meters to miles
        return miles
    }
}
