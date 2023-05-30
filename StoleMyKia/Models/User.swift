//
//  User.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 5/7/23.
//

import Foundation


struct FirebaseUser: Codable {
    
    let uid: String
    var notificationSettings: NotificationSettings
    var vehicle: Vehicle?
    var updates: [UUID]
    var bookmarks: [UUID]
}


struct NotificationSettings: Codable {
    
    var notifyOfTheft: Bool   = true
    var notifyOfWitness: Bool = true
    var notifyOfFound:Bool    = true
    var notificationRadius    = 25000.0
}
