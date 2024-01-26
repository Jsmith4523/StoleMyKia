//
//  Formatters.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 8/4/23.
//

import Foundation

class ApplicationFormats {
    
    private init() {}
    
    /// Formats a phone number in XXX-XXX-XXXX format
    /// - Parameter phoneNumber: The phone number to format.
    /// - Returns: The formatted number for Firebase Auth or displaying
    static func authPhoneNumberFormat(_ phoneNumber: String?, parentheses: Bool = false) -> String? {
        guard let pn = phoneNumber, pn.count == 10 else { return nil}
        
        let phoneNumber = pn.replacingOccurrences(of: "[^a-zA-Z]", with: "")
        var formattedNumber = ""
        
        let firstIndices = [0,1,2]
        let left: String = firstIndices
            .map{phoneNumber[String.Index(utf16Offset: $0, in: phoneNumber)]}
            .map({"\($0)"})
            .joined()
        
        let middleIndices = [3,4,5]
        let middle: String = middleIndices
            .map({phoneNumber[String.Index(utf16Offset: $0, in: phoneNumber)]})
            .map({"\($0)"})
            .joined()
            .appending("-")
        
        let rightIndices = [6,7,8,9]
        let right: String = rightIndices
            .map({phoneNumber[String.Index(utf16Offset: $0, in: phoneNumber)]})
            .map({"\($0)"})
            .joined()
        if parentheses {
            formattedNumber.append(contentsOf: "+1"+" (\(left)) "+middle+right)
        } else {
            formattedNumber.append(contentsOf: "+1"+"\(left)-"+middle+right)
        }
        
        return formattedNumber
    }
    
    /// Displays a vehicle license plate discretely
    /// - Parameter vin: Vehicle vin in string value
    /// - Returns: A formatted vin
    static func licenseFormat(_ license: String) -> String {
        var str = "***"
        
        let licenseArray = license.compactMap({$0})
        
        for char in licenseArray[abs(license.count / 2)...license.count-1] {
            str.append("\(char)")
        }
        return str
    }
    
    /// Displays a vehicle VIN discretely
    /// - Parameter vin: Vehicle vin in string value
    /// - Returns: A formatted vin
    static func vinFormat(_ vin: String) -> String? {
        var str = "*****"
        
        guard vin.count >= 14 else {
            return nil
        }
        
        let vinArray = vin.compactMap({$0})
        
        for character in vinArray[11...vin.count-1] {
            str.append("\(character)")
        }
        
        return str
    }
    
    static func dateFormat(_ interval: TimeInterval, format: String = "M.dd.yy - h:mma") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        let date = Date(timeIntervalSince1970: interval)
        let string = formatter.string(from: date)
        return string
    }
    
    static func timeAgoFormat(_ interval: TimeInterval) -> String {
        let opposingDate = Date(timeIntervalSince1970: interval)
        let secondsBetweenDates = Int(Date().timeIntervalSince(opposingDate))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 4 * week
        
        if secondsBetweenDates == 0 {
            return "Just Now"
        } else if secondsBetweenDates < 0 {
            return opposingDate.formatted(date: .numeric, time: .omitted)
        } else if secondsBetweenDates < minute {
            return "\(secondsBetweenDates)s ago"
        } else if secondsBetweenDates < hour {
            return "\(secondsBetweenDates / minute)m ago"
        } else if secondsBetweenDates < day {
            return "\(secondsBetweenDates / hour)h ago"
        } else if secondsBetweenDates < week {
            return "\(secondsBetweenDates / day)d ago"
        } else if secondsBetweenDates < month {
            return "\(secondsBetweenDates / week)wk ago"
        } else {
            return opposingDate.formatted(date: .numeric, time: .omitted)
        }
    }
}
