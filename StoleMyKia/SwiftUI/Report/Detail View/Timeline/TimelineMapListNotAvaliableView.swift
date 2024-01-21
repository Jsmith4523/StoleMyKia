//
//  TimelineMapListNotAvaliableView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 1/9/24.
//

import SwiftUI

struct TimelineMapListNotAvaliableView: View {
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 115)
            VStack(spacing: 15) {
                Image(systemName: "archivebox")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 45, height: 45)
                VStack(spacing: 5) {
                    Text("No Longer Available")
                        .font(.system(size: 22).weight(.heavy))
                    Text("Sorry, the initial report can no longer receive updates.")
                        .font(.system(size: 16))
                }
            }
        }
        .padding()
        .multilineTextAlignment(.center)
    }
}

#Preview {
    TimelineMapListNotAvaliableView()
}
