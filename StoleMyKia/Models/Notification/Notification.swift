//
//  FirebaseUserNotification.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/9/23.
//

import Foundation
import SwiftUI

struct AppUserNotification: Identifiable, Decodable {
    
    static let isReadKey = "isRead"
    
    enum UserNotificationType: String, CaseIterable, Identifiable, Codable {
        
        case report      = "Report"
        case update      = "Update"
        case falseReport = "False Report"
        
        var id: Self {
            return self
        }
    }
    
    //The id is applied through the firebase functions
    var id: String
    let dt: TimeInterval
    let title: String
    let body: String
    let notificationType: UserNotificationType
    let reportId: UUID
    var isRead: Bool
    var imageUrl: String?
}

extension AppUserNotification {
    
    var hasImage: Bool {
        !(imageUrl == nil)
    }
    
    var dateAndTime: String {
        return ApplicationFormats.timeAgoFormat(self.dt)
    }
}
