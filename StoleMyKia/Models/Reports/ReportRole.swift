//
//  ReportRole.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/19/23.
//

import Foundation


enum ReportRole: Identifiable, Codable, Equatable {
    
    case original
    //Parent report UUID
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
