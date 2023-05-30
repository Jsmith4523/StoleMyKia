//
//  NoUpdatesView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 5/29/23.
//

import SwiftUI

struct NoUpdatesView: View {
    var body: some View {
        VStack(spacing: 20) {
            UserAccountViewSelection.updates.indicator
                .resizable()
                .scaledToFit()
                .frame(width: 45, height: 45)
                .foregroundColor(.brand)
            Text("Updates will appear here")
                .font(.system(size: 21).weight(.heavy))
            Text("Any updates you make to a report will show here. This includes updates to reports you have made.")
                .font(.system(size: 16))
                .foregroundColor(.gray)
        }
        .padding()
        .multilineTextAlignment(.center)
    }
}

struct NoUpdatesView_Previews: PreviewProvider {
    static var previews: some View {
        NoUpdatesView()
    }
}
