//
//  NearbyLocationSearchErrorView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 7/23/23.
//

import SwiftUI

struct NearbyLocationSearchErrorView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("We ran into an error finding nearby locations. Please try again")
                .font(.system(size: 17))
                .foregroundColor(.gray)
            Spacer()
        }
        .multilineTextAlignment(.center)
        .padding()
    }
}

//#Preview {
//    NearbyLocationSearchErrorView()
//}
