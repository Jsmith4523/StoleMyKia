//
//  TimelineMapListNoUpdatesView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 1/9/24.
//

import SwiftUI

struct TimelineMapListNoUpdatesView: View {
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 135)
            VStack(spacing: 15) {
                Image.updateImageIcon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 45, height: 45)
                VStack(spacing: 5) {
                    Text("No Updates")
                        .font(.system(size: 22).weight(.heavy))
                    Text("This report has not received any recent updates.")
                        .font(.system(size: 17))
                }
            }
        }
        .multilineTextAlignment(.center)
        .padding()
    }
}

#Preview {
    ScrollView {
        TimelineMapListNoUpdatesView()
    }
}
