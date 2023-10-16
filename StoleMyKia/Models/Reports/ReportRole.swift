//
//  ReportRole.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/19/23.
//

import Foundation


enum ReportRole: Identifiable, Codable, Equatable, Comparable {
    
    enum Role: String, Identifiable, Comparable, CaseIterable {
        
        case original = "Initial Report"
        case update = "Update"
        
        var id: String {
            self.rawValue
        }
        
        static func < (lhs: ReportRole.Role, rhs: ReportRole.Role) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
        
        static func > (lhs: ReportRole.Role, rhs: ReportRole.Role) -> Bool {
            lhs.rawValue > rhs.rawValue
        }
    }
    
    ///This is a original report.
    case original(UUID)
    ///This is an update report. The enum holds the UUID value of the original report it's updating.
    case update(UUID)
    
    var id: String {
        self.title
    }
    
    ///The associated value with this role.
    var associatedValue: UUID {
        switch self {
        case .original(let uuid):
            return uuid
        case .update(let uuid):
            return uuid
        }
    }
    
    var title: String {
        switch self {
        case .original:
            return "Original"
        case .update:
            return "Update"
        }
    }
    
    var image: String {
        switch self {
        case .original:
            return "arrow.up"
        case .update:
            return "arrow.2.squarepath"
        }
    }
    
    var allowsForUpdates: Bool {
        switch self {
        case .original:
            return true
        case .update:
            return false
        }
    }
    
    var notificationTitle: String {
        switch self {
        case .original:
            return "Report"
        case .update:
            return "Update"
        }
    }
    
    var hasParent: Bool {
        switch self {
        case .original:
            return true
        case .update:
            return false
        }
    }
    
    var isAnUpdate: Bool {
        switch self {
        case .original(_):
            return false
        case .update(_):
            return true
        }
    }
    
    var role: Self.Role {
        switch self {
        case .original:
            return .original
        case .update:
            return .update
        }
    }
    
    var falseReportDescription: String {
        switch self {
        case .original(_):
            return "We have determined that this report is false. This report can no longer be updated"
        case .update(_):
            return "We have determined that this update is false. The original report cannot be updated through this report."
        }
    }
    
    var discloseRadiusSize: CGFloat {
        switch self.role {
        case .original:
            return 1250
        case .update:
            return 450
        }
    }
    
    static func < (lhs: ReportRole, rhs: ReportRole) -> Bool {
        lhs.title < rhs.title
    }
    
    static func > (lhs: ReportRole, rhs: ReportRole) -> Bool {
        lhs.title > rhs.title
    }
}
