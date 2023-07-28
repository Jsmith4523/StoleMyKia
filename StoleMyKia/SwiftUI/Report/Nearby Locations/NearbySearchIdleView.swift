//
//  SearchView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 7/23/23.
//

import SwiftUI

struct NearbySearchIdleView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Begin searching for nearby locations..")
                .font(.system(size: 17))
                .foregroundColor(.gray)
            Spacer()
        }
        .multilineTextAlignment(.center)
        .padding()
    }
}

//#Preview {
//    NearbySearchIdleView()
//}
