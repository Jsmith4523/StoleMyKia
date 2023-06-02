//
//  NoNotificationsView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/1/23.
//

import SwiftUI

struct NoNotificationsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.bubble")
                .resizable()
                .scaledToFit()
                .frame(width: 85, height: 85)
                .foregroundColor(.brand)
            Text("Nothing to report")
                .font(.system(size: 25).weight(.heavy))
            Text("Once we recieve intel on something, you will be alert here")
        }
        .padding()
        .multilineTextAlignment(.center)
    }
}

struct NoNotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NoNotificationsView()
    }
}
