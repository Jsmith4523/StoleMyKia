//
//  FirebaseUserNotification.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/9/23.
//

import Foundation
import SwiftUI

enum NotificationType: Codable, Identifiable {
    case notification, update
    
    var id: String {
        return self.title
    }
    
    var title: String {
        switch self {
        case .notification:
            return "Report"
        case .update:
            return "Update"
        }
    }
    
    var symbol: String {
        switch self {
        case .notification:
            return ApplicationTabViewSelection.notification.symbol
        case .update:
            return "arrow.triangle.swap"
        }
    }
    
    var color: Color {
        switch self {
        case .notification:
            return .yellow
        case .update:
            return .brown
        }
    }
}

struct FirebaseNotification: Identifiable, Codable, Comparable {
    
    static func < (lhs: FirebaseNotification, rhs: FirebaseNotification) -> Bool {
        lhs.report.dt < rhs.report.dt
    }
    
    static func > (lhs: FirebaseNotification, rhs: FirebaseNotification) -> Bool {
        lhs.report.dt > rhs.report.dt
    }
    
    static let isRead = "isRead"
    
    var id = UUID()
    ///The report of this notification
    let report: Report
    ///Whether the user did or did not read this notification
    var isRead: Bool = false
    var notificationType: NotificationType
}

extension [FirebaseNotification] {
    
    static func dummyNotifications() -> [FirebaseNotification] {
        [FirebaseNotification]()
    }
}
