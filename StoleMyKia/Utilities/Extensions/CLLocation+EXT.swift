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
        return "\(String(format: "%.1f", miles)) mi."
    }
}

extension CLLocationCoordinate2D {
    
    var location: CLLocation {
        CLLocation(latitude: self.latitude, longitude: self.longitude)
    }
}

extension MKCoordinateSpan {
    
    static var halfAMile: MKCoordinateSpan {
        return MKCoordinateSpan(latitudeDelta: 0.007236, longitudeDelta: 0.007236)
    }
}

extension MKCircle {
    
    static let discloseLocationFillColor: UIColor = .systemBlue.withAlphaComponent(0.25)
    static let discloseLocationRadius: Double = 1250
    static let discloseLocationEdgePadding: UIEdgeInsets = .init(top: 200, left: 100, bottom: 150, right: 200)
}

extension MKPolyline {
    
    var timelineEdgePadding: UIEdgeInsets {
        return .init(top: 50, left: 50, bottom: 50, right: 50)
    }
}
