//
//  Image+EXT.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/15/23.
//

import Foundation
import SwiftUI

extension Image {
    
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

extension UIImage? {
    
    
    func isNil() -> Bool {
        self == nil
    }
}
