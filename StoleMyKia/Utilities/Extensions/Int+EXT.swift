//
//  Int+EXT.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 9/8/23.
//

import Foundation
import UIKit

extension CGFloat {
    
    static let scrollViewHeightOffset = UIScreen.main.bounds.height/2-200
}

extension Int {
    
    static let descriptionMinCharacterCount = 25
    static let descriptionWarningCharacterCount = Self.descriptionMaxCharacterCount - 75
    static let descriptionMaxCharacterCount = 600
    
    ///Returns a string value of this number with "10+" if n > 10
    var limitToTen: String {
        if self > 10 {
            return "10+"
        }
        return "\(self)"
    }
}

extension Int? {
    
    func isNil() -> Bool {
        self == nil
    }
}
