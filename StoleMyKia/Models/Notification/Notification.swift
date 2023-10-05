//
//  FirebaseUserNotification.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/9/23.
//

import Foundation
import SwiftUI

struct `Notification`: Identifiable, Codable {
    
    static let isReadKey = "isRead"
    
    enum NotificationType: String, CaseIterable, Identifiable, Codable {
        
        case report      = "Report"
        case update      = "Update"
        case falseReport = "False Report"
        
        var id: Self {
            return self
        }
    }
    
    var id = UUID()
    let dt: TimeInterval
    let title: String
    let body: String
    let notificationType: NotificationType
    let reportId: UUID
    var isRead: Bool
    let imageUrl: String?
}

extension Notification {
    
    var hasImage: Bool {
        !(imageUrl == nil)
    }
    
    var dateAndTime: String {
        return ApplicationFormats.timeAgoFormat(self.dt)
    }
}
