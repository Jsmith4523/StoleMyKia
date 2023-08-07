//
//  NotificationView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/10/23.
//

import SwiftUI

struct NotificationView: View {
    
    @State private var isShowingNotificationSettingsView = false
    
    @EnvironmentObject var notificationVM: NotificationViewModel
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var reportsVM: ReportsViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                switch notificationVM.notificationLoadStatus {
                case .loading:
                    ProgressView()
                case .loaded:
                    switch notificationVM.userNotifications.isEmpty {
                    case true:
                        NoNotificationsView()

                    case false:
                        NotificationListView()
                    }
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .environmentObject(notificationVM)
            .environmentObject(userVM)
            .environmentObject(reportsVM)
            .onAppear {
                fetchForUserNotifications()
            }
        }
    }
    
    private func fetchForUserNotifications() {
        //FIXME: FirebaseUserDelegate is nil within this view and will fatally crash once switch the guard statement to test for false cases if shown on Preview Provider
//        guard notificationVM.userNotifications.isEmpty else { return }
//        notificationVM.fetchFirebaseUserNotifications()
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView()
            .environmentObject(NotificationViewModel())
            .environmentObject(UserViewModel())
            .environmentObject(ReportsViewModel())
    }
}
