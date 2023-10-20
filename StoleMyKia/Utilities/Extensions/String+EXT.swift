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
    
    static let reportSymbolName = "newspaper"
    static let updateSymbolName = "arrow.2.squarepath"
    static let falseReportSymbolName = "exclamationmark.shield"
    
    func createHash() -> String {
        let data = Data(self.utf8)
        let hash = SHA256.hash(data: data)
                
        return hash.compactMap{String(format: "%02x", $0)}.joined()
    }
}

extension Text {
    func authButtonStyle(background: Color = .brand) -> some View {
        return self
            .padding()
            .frame(width: 310)
            .font(.system(size: 22).weight(.heavy))
            .background(background)
            .foregroundColor(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

