//
//  FeedNoDesiredLocationView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 1/14/24.
//

import SwiftUI

struct FeedNoDesiredLocationView: View {
    var body: some View {
        VStack {
            VStack(spacing: 15) {
                Spacer()
                    .frame(height: 150)
                Image(systemName: "globe.americas.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                VStack(spacing: 7) {
                    Text("Set Your Desired Location")
                        .font(.system(size: 19).weight(.heavy))
                    Text("We've noticed that you do not have a desired location set. You can do so by pressing the icon on the top-right of this screen. This desired location is where you'll receive reports within that area.")
                        .font(.system(size: 15.65))
                        .multilineTextAlignment(.center)
                }
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    FeedNoDesiredLocationView()
}
