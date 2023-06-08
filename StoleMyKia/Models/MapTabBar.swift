//
//  MapTabBar.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/8/23.
//

import SwiftUI

struct MapTabBar: View {
    var body: some View {
        HStack {
            Button {
                
            } label: {
                Label("Report Theft", systemImage: "exclamationmark.triangle.fill")
                    .foregroundColor(.white)
                    .frame(width: 350, height: 50)
                    .background(Color.brand)
                    .cornerRadius(15)
            }
        }
        .padding()
    }
}

struct MapTabBar_Previews: PreviewProvider {
    static var previews: some View {
        MapTabBar()
    }
}
