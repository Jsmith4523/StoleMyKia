//
//  ApplicationTabBarView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/7/23.
//

import SwiftUI

struct ApplicationTabBarView: View {
    
    @Binding var selection: ApplicationTabViewSelection
    
    var body: some View {
        HStack {
            
        }
    }
}

#Preview {
    ApplicationTabBarView(selection: .constant(.notification))
}
