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
    
    var date: String {
        self.formatted(.dateTime.month().day().year())
    }
    
    var time: String {
        self.formatted(.dateTime.hour().minute())
    }
}

extension TimeInterval {
    
    
    var time: String {
        Date(timeIntervalSince1970: self).time
    }
    
    var date: String {
        Date(timeIntervalSince1970: self).date
    }
    
    var full: String {
        Date(timeIntervalSince1970: self).formatted(date: .abbreviated, time: .shortened)
    }
}
