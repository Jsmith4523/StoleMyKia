//
//  Constants.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 7/13/23.
//

import Foundation

///Contains string constants of database path locations within Firebase, Firestore, and Storage
struct FirebaseDatabasesPaths {
    ///Path to all users.
    static let usersDatabasePath             = "Users/"
    ///Path to a users bookmarked reports
    static let userBookmarksPath             = "bookmarks"
    ///Path to a logged in users notifications.
    static let userNotificationDatabasePath  = "Users/Notifications/"
    ///Path to vehicle images for reports
    static let reportVehicleImageStoragePath = "Vehicles/Reports/"
    ///Path to user vehicle images
    static let usersVehicleImageStoragePath  = "Vehicles/Users/"
    ///Path for vehicle reports
    static let reportsDatabasePath           = "Reports/"
}
