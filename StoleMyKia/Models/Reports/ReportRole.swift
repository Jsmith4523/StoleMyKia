//
//  ReportRole.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/19/23.
//

import Foundation


enum ReportRole: Identifiable, Codable, Equatable {
    
    ///This is a original report.
    case original(UUID)
    ///This is an update report. The enum holds the UUID value of the original report it's updating.
    case update(UUID)
    
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
            return "Report"
        case .update(_):
            return "Update"
        }
    }
    
    var allowsForUpdates: Bool {
        switch self {
        case .original(_):
            return true
        case .update(_):
            return false
        }
    }
    
    var notificationTitle: String {
        switch self {
        case .original(_):
            return "Report"
        case .update(_):
            return "Update"
        }
    }
    
    var hasParent: Bool {
        switch self {
        case .original(_):
            return true
        case .update(_):
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
    
    var falseReportDescription: String {
        switch self {
        case .original(_):
            return "We have determined that this report is false. This report can no longer be updated"
        case .update(_):
            return "We have determined that this update is false. The original report cannot be updated through this report."
        }
    }
    
    var id: String {
        self.title
    }
}
