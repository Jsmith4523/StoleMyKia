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
    static let userBookmarksPath             = "Bookmarks"
    ///Path to a user settings
    static let userSettingsPath              = "Settings"

    static let userNotificationSettings      = "Notifications"
    ///Path to a logged in users notifications.
    static let userNotificationPath          = "Notifications"
    ///Path to vehicle images for reports
    static let reportVehicleImageStoragePath = "Vehicles/Reports/"
    ///Path to user vehicle images
    static let usersVehicleImageStoragePath  = "Vehicles/Users/"
    ///Path for vehicle reports
    static let reportsDatabasePath           = "Reports/"
    ///Path to Firebase users FCM tokens
    static let fcmTokenPath                  = "FcmTokens"
    ///Path to the updates of a report
    static let reportUpdatesPath             = "Reports/Updates/"
    ///Path to set a false report so admins can review it
    
    //MARK: False Reports
    static let falseReportsPath              = "FalseReports/"
    static let userOpenFalseReports          = "Opened"
    static let userClosedFalseReports        = "Closed"
}
