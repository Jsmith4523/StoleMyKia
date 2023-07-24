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
    
    init(coordinates: CLLocationCoordinate2D) {
        self.lat = coordinates.latitude
        self.lon = coordinates.longitude
    }
    
    init(address: String?, name: String?, coordinate: CLLocationCoordinate2D) {
        self.address = address
        self.name = name
        self.lat = coordinate.latitude
        self.lon = coordinate.longitude
    }
    
    init(address: String?, name: String?, lat: Double, lon: Double) {
        self.address = address
        self.name = name
        self.lat = lat
        self.lon = lon
    }
    
    var id = UUID()
    var address: String? = nil
    var name: String? =  nil
    let lat: Double
    let lon: Double
}

extension Location {
    
    private static func userLocation() -> CLLocation? {
        guard let userLocation = CLLocationManager.shared.location else { return nil}
        return userLocation
    }
    
    static func > (lhs: Location, rhs: Location) -> Bool {
        return lhs.location.distance(from: rhs.location) > rhs.location.distance(from: lhs.location)
    }
    
    static func < (lhs: Location, rhs: Location) -> Bool {
        return lhs.location.distance(from: rhs.location) > rhs.location.distance(from: lhs.location)
    }
    
    ///Location distance from the user in miles.
    var distanceFromUser: String {
        guard let userLocation = Self.userLocation() else { return ""}
        return userLocation.calculateDistanceInMilesString(to: self.location)
    }
        
    var location: CLLocation {
        CLLocation(latitude: lat, longitude: lon)
    }

    var coordinates: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    var region: MKCoordinateRegion {
        MKCoordinateRegion(center: self.coordinates, span: .init(latitudeDelta: 0.0025, longitudeDelta: 0.0025))
    }
    
    var hasAddress: Bool {
        guard let address, !(address.isEmpty) else {
            return false
        }
        
        return true
    }
    
    var hasName: Bool {
        guard let name, !(name.isEmpty) else {
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
