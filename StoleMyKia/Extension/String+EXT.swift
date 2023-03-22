//
//  String+EXT.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/22/23.
//

import Foundation
import CryptoKit

extension String {
    
    func createHash() -> String {
        let data = Data(self.utf8)
        let hash = SHA256.hash(data: data)
                
        return hash.compactMap{String(format: "%02x", $0)}.joined()
    }
}
