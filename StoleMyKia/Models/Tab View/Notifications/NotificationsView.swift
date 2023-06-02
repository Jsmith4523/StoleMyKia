//
//  NotificationsView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/13/23.
//

import SwiftUI

struct NotificationsView: View {
    
    @EnvironmentObject var notificationModel: NotificationViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                NoNotificationsView()
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
            .environmentObject(NotificationViewModel())
    }
}
