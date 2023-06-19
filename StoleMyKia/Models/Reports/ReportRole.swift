//
//  ReportRole.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/19/23.
//

import Foundation


enum ReportRole: Identifiable, Codable {
    
    case original, update
    
    var title: String {
        switch self {
        case .original:
            return "Original"
        case .update:
            return "Update"
        }
    }
    
    var id: String {
        self.title
    }
}
