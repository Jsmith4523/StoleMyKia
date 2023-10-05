//
//  NotificationView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 8/12/23.
//

import SwiftUI

struct NotificationView: View {
    
    @EnvironmentObject var notificationVM: NotificationViewModel
    @EnvironmentObject var reportsVM: ReportsViewModel
    @EnvironmentObject var userVM: UserViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                ZStack(alignment: .center) {
                    switch notificationVM.loadStatus {
                    case .empty:
                        NotificationEmptyView()
                    case .loaded:
                        NotificationListView()
                    case .loading:
                        NotificationSkeletonProgressView()
                    }
                }
            }
            .navigationTitle(ApplicationTabViewSelection.notification.title)
            .navigationBarTitleDisplayMode(.inline)
            .environmentObject(notificationVM)
            .environmentObject(reportsVM)
            .environmentObject(userVM)
            .onAppear {
                if notificationVM.notifications.isEmpty {
                    notificationVM.fetchNotifications()
                }
            }
            .refreshable {
                notificationVM.fetchNotifications()
            }
        }
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView()
            .environmentObject(NotificationViewModel())
            .environmentObject(ReportsViewModel())
            .environmentObject(UserViewModel())
    }
}
