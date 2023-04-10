//
//  Date+EXT.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/22/23.
//

import Foundation

extension Date {
    
    var distance: String {
        self.distance(to: .now).formatted()
    }

    var epoch: TimeInterval {
        self.timeIntervalSince1970
    }
}
