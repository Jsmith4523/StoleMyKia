//
//  User.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 5/7/23.
//

import Foundation
import CoreLocation

struct UserNotification {
    
    var notificationSettings: UserNotificationSettings
}

struct UserNotificationSettings: Codable {
    
    var location: UserNotificationLocation?
    
    var notifyAttempt = false
    var notifyBreakIn = false
    var notifyCarjacking = false
    var notifyRecovered = false
    var notifyIncident = false
    var notifyLocated = false
    var notifyStolen = false
    var notifyWitnessed = false
    
    struct UserNotificationLocation: Codable {
        var lat: Double
        var long: Double
        var radius: Double = NearbyDistance.fiveMiles.distance
    }
}


extension UserNotificationSettings.UserNotificationLocation {
    
    var coordinate: CLLocationCoordinate2D {
        return .init(latitude: self.lat,
                     longitude: self.long)
    }
}
