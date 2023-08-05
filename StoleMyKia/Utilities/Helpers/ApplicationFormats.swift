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
    static func authPhoneNumberFormat(_ phoneNumber: String) -> String? {
        guard phoneNumber.count == 10 else { return nil}
        
        let phoneNumber = phoneNumber.replacingOccurrences(of: "[^a-zA-Z]", with: "")
        var formattedNumber = ""
        
        let firstIndices = [0,1,2]
        let left: String = firstIndices
            .map{phoneNumber[String.Index(utf16Offset: $0, in: phoneNumber)]}
            .map({"\($0)"})
            .joined()
            .appending("-")
        
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
        
        formattedNumber.append(contentsOf: "+1"+left+middle+right)
        print(formattedNumber)
        
        return formattedNumber
    }
    
    /// Displays a vehicle license plate discretely
    /// - Parameter vin: Vehicle vin in string value
    /// - Returns: A formatted vin
    static func licenseFormat(_ license: String) -> String {
        var str = "***"
        
        let licenseArray = license.compactMap({$0})
        
        for char in licenseArray[4...license.count-1] {
            str.append("\(char)")
        }
        return str
    }
    
    /// Displays a vehicle VIN discretely
    /// - Parameter vin: Vehicle vin in string value
    /// - Returns: A formatted vin
    static func vinFormat(_ vin: String) -> String {
        var str = "*****"
        
        let vinArray = vin.compactMap({$0})
        
        for character in vinArray[11...vin.count-1] {
            str.append("\(character)")
        }
        
        return str
    }
}
