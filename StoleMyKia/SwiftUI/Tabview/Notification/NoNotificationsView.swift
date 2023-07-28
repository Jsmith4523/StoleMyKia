//
//  NoNotificationsView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 7/13/23.
//

import SwiftUI

struct NoNotificationsView: View {
    
    @EnvironmentObject var notificationVM: NotificationViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                Spacer()
                    .frame(height: 135)
                VStack(spacing: 15) {
                    Image(systemName: ApplicationTabViewSelection.notification.symbol)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35)
                    VStack(spacing: 7) {
                        Text("You don't have any notifications at the moment.")
                            .font(.system(size: 18).bold())
                        Text("Pull this screen down to refresh.")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
            }
            .multilineTextAlignment(.center)
            .padding()
        }
        .refreshable {
            notificationVM.fetchFirebaseUserNotifications()
        }
    }
}

struct NoNotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NoNotificationsView()
    }
}
