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

struct Notification: Identifiable, Decodable {
    let id: UUID
    let dt: TimeInterval
    let title: String
    let body: String
    let reportType: ReportType
    let reportId: UUID
    var isRead: Bool
    let imageUrl: String?
}

extension Notification {
    
    var hasImage: Bool {
        !(imageUrl == nil)
    }
    
    var timeAgoSince: String {
        Date(timeIntervalSince1970: self.dt).timeAgoDisplay()
    }
}
