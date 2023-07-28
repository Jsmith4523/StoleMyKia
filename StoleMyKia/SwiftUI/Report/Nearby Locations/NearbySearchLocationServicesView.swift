//
//  NearbySearchLocationServicesView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 7/23/23.
//

import SwiftUI

struct NearbySearchLocationServicesView: View {
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 15) {
                Image(systemName: "location.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
                    .foregroundColor(.blue)
                Text("Your location services are disabled. Enable them in order to find nearby locations.")
                    .font(.system(size: 17))
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .multilineTextAlignment(.center)
    }
}

//#Preview {
//    NearbySearchLocationServicesView()
//}
