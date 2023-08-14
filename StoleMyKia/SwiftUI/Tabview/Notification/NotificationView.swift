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
            ZStack {
                NotificationListView()
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .environmentObject(notificationVM)
            .environmentObject(reportsVM)
            .environmentObject(userVM)
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
