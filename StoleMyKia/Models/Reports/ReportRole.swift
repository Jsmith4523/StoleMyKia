//
//  ReportRole.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/19/23.
//

import Foundation


enum ReportRole: Identifiable, Codable, Equatable {
    
    ///This is a original report
    case original
    ///This is an update report. The enum holds the UUID value of the original report it updates
    case update(UUID)
    
    var title: String {
        switch self {
        case .original:
            return "Original"
        case .update(_):
            return "Update"
        }
    }
    
    var id: String {
        self.title
    }
}
