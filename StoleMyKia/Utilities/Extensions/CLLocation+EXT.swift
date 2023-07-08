//
//  CLLocationManager+EXT.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/13/23.
//

import Foundation
import MapKit

extension CLLocationManager {
    
    ///Shared instance
    static var shared: CLLocationManager {
        CLLocationManager()
    }
    
    ///Will retrieve the CLLocationCord2D of the users location If authorized.
    var usersCurrentLocation: CLLocationCoordinate2D? {
        self.location?.coordinate
    }
}

extension CLAuthorizationStatus {
    
    var isAuthorized: Bool {
        self == .authorizedAlways || self == .authorizedWhenInUse
    }
}

extension CLAuthorizationStatus? {
    
    func isAuthorized() -> Bool {
        !(self == nil) && self == .authorizedWhenInUse || self == .authorizedAlways
    }
}

extension CLLocation {
    
    func calculateDistanceInMiles(to destinationLocation: CLLocation) -> CLLocationDistance {
        let meters = self.distance(from: destinationLocation)
        let miles = meters * 0.000621371 // Convert meters to miles
        return miles
    }

    func calculateDistanceInMilesString(to destinationLocation: CLLocation) -> String {
        let meters = self.distance(from: destinationLocation)
        let miles = meters * 0.000621371 // Convert meters to miles
        return "\(String(format: "%.2f", miles)) \(miles > 1 ? "miles" : "mile") away"
    }
}
