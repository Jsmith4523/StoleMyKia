//
//  Image+EXT.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/15/23.
//

import Foundation
import SwiftUI

extension Image {
    
    static let vehiclePlaceholder = Image("vehicle-placeholder")
    static let userPlaceholder = Image("user-placeholder")
    
    func floatingButtonStyle() -> some View {
        return self
            .resizable()
            .scaledToFit()
            .frame(width: 15, height: 15)
            .padding(10)
            .foregroundColor(.black)
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(Circle())
            .shadow(radius: 4)
    }
}
