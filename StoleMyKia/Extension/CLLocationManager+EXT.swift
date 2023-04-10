//
//  CLLocationManager+EXT.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/13/23.
//

import Foundation
import MapKit

extension CLLocationManager {
    
    ///Will retrieve the CLLocationCord2D of the users location If authroized.
    var usersCurrentLocation: CLLocationCoordinate2D? {
        self.location?.coordinate
    }
}

extension CLAuthorizationStatus? {
    
    func isAuthorized() -> Bool {
        !(self == nil) && self == .authorizedWhenInUse || self == .authorizedAlways
    }
}
