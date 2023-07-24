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
    
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
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
    
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        let date = Date(timeIntervalSince1970: self)
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    func timeBetweenDates(interval: TimeInterval) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        let date = Date(timeIntervalSince1970: self)
        let referenceDate = Date(timeIntervalSince1970: interval)
        return formatter.localizedString(for: date, relativeTo: referenceDate)
    }
}
