//
//  NearbySearchUserLocationErrorView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 7/23/23.
//

import SwiftUI

struct NearbySearchUserLocationErrorView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("We ran into an issue locating your. Please try again.")
                .font(.system(size: 17))
                .foregroundColor(.gray)
            Spacer()
        }
        .multilineTextAlignment(.center)
        .padding()
        .padding(.horizontal)
    }
}

//#Preview {
//    NearbySearchUserLocationErrorView()
//}
