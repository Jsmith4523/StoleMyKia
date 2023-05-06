//
//  AboutAppView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/22/23.
//

import Foundation
import SwiftUI


struct AboutAppView: View {
    var body: some View {
        List {
            
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MyPreviewProvider_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AboutAppView()
        }
    }
}
