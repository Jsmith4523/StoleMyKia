//
//  String+EXT.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/22/23.
//

import Foundation
import CryptoKit
import SwiftUI

extension String {
    
    func createHash() -> String {
        let data = Data(self.utf8)
        let hash = SHA256.hash(data: data)
                
        return hash.compactMap{String(format: "%02x", $0)}.joined()
    }
    
    func vinFormat() -> String? {
        var str = "**********"
        
        let vinArray = self.compactMap({$0})
        
        guard self.count >= 17 else {
            return nil
        }
        
        for character in vinArray[11...self.count-1] {
            str.append("\(character)")
        }
        
        return str
    }
}
