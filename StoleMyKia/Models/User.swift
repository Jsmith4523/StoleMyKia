//
//  User.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 5/7/23.
//

import Foundation


struct FirebaseUser: Codable {
    
    ///The firebase users uid
    let uid: String
    ///The users notification settings
    var notificationSettings: NotificationSettings = NotificationSettings()
    ///The users bookmarked reports by uuid
    var bookmarks: [UUID]?
    ///The users vehicle
    var vehicle: Vehicle?
}

struct NotificationSettings: Codable {
    
    var notifyOfCarjacking: Bool = true
    var notifyOfTheft: Bool      = true
    var notifyOfWitness: Bool    = true
    var notifyOfFound: Bool      = true
    var notifyOfSpotted: Bool    = true
    var notificationRadius       = 25000.0
    var lattitude: Double?
    var longtitude: Double?
}

extension FirebaseUser {
    
    
    func hasBookmark(_ id: UUID) -> Bool {
        self.bookmarks?.contains { $0.uuidString == id.uuidString } ?? false
    }
    
    mutating func addReportToBookmark(_ id: UUID) {
        if (bookmarks == nil) {
            self.bookmarks = []
        }
        self.bookmarks?.append(id)
    }
    
    mutating func removeReportFromBookmark(_ id: UUID) {
        self.bookmarks?.removeAll { $0.uuidString == id.uuidString}
    }
}
