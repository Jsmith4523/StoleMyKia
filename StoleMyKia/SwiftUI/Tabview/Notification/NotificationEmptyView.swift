//
//  NotificationEmptyView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/4/23.
//

import SwiftUI

struct NotificationEmptyView: View {
    var body: some View {
        VStack {
            Spacer()
                .frame(height: .scrollViewHeightOffset)
            VStack(spacing: 20) {
                Image(systemName: ApplicationTabViewSelection.notification.symbol)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                Text("You don't have any notifications at the moment.")
                    .font(.system(size: 19))
            }
        }
        .foregroundColor(.gray)
        .multilineTextAlignment(.center)
        .padding()
    }
}

struct NotificationEmptyView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            NotificationEmptyView()
        }
    }
}
