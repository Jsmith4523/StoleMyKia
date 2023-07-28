//
//  NearbySearchNoResultsView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 7/23/23.
//

import SwiftUI

struct NearbySearchNoResultsView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Sorry, we couldn't find any locations with that request.")
                .font(.system(size: 17))
                .foregroundColor(.gray)
            Spacer()
        }
        .multilineTextAlignment(.center)
        .padding()
    }
}

#Preview {
    NearbySearchNoResultsView()
}
