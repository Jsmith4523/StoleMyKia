//
//  NotificationView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 8/12/23.
//

import SwiftUI

struct NotificationView: View {
    
    @ObservedObject var notificationVM: NotificationViewModel
    @ObservedObject var reportsVM: ReportsViewModel
    @ObservedObject var userVM: UserViewModel
    
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
        NotificationView(notificationVM: NotificationViewModel(), reportsVM: ReportsViewModel(), userVM: UserViewModel())
    }
}
