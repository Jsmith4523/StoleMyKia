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
    
    static let reportSymbolName = "newspaper.fill"
    static let updateSymbolName = "arrow.2.squarepath"
    static let falseReportSymbolName = "exclamationmark.shield"
    
    func createHash() -> String {
        let data = Data(self.utf8)
        let hash = SHA256.hash(data: data)
                
        return hash.compactMap{String(format: "%02x", $0)}.joined()
    }
}
