//
//  ApplicationTabView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/10/23.
//

import SwiftUI

enum ApplicationTabViewSelection {
    
    case feed, notification, search, user
    
    var title: String {
        switch self {
        case .feed:
            return "Reports"
        case .notification:
            return "Notifications"
        case .user:
            return "My Account"
        case .search:
            return "Search"
        }
    }
    
    var symbol: String {
        switch self {
        case .feed:
            return "newspaper"
        case .notification:
            return "bell"
        case .user:
            return "person.crop.circle"
        case .search:
            return "magnifyingglass"
        }
    }
    
    var tabItemLabel: some View {
        return Label(self.title, systemImage: self.symbol)
    }
}

struct ApplicationTabView: View {
    
    @State private var notificationCount = 0
    @State private var selection: ApplicationTabViewSelection = .feed
    
    @StateObject private var reportsVM = ReportsViewModel()
    @StateObject private var notificationVM = NotificationViewModel()
    @EnvironmentObject var userModel: UserViewModel
        
    var body: some View {
        TabView(selection: $selection) {
            FeedView()
                .tag(ApplicationTabViewSelection.feed)
                .tabItem {
                    ApplicationTabViewSelection.feed.tabItemLabel
                }
            SearchView()
                .tag(ApplicationTabViewSelection.search)
                .tabItem {
                    ApplicationTabViewSelection.search.tabItemLabel
                }
            NotificationView()
                .tag(ApplicationTabViewSelection.notification)
                .badge(notificationCount)
                .tabItem {
                    ApplicationTabViewSelection.notification.tabItemLabel
                }
            UserView()
                .tag(ApplicationTabViewSelection.user)
                .tabItem {
                    ApplicationTabViewSelection.user.tabItemLabel
                }
        }
        .environmentObject(reportsVM)
        .environmentObject(userModel)
        .environmentObject(notificationVM)
        .tint(Color(uiColor: .label))
        .onReceive(notificationVM.$userNotifications) { notifications in
            //Settings the NotificationView badge count to the number of un-read notifications...
            //This code is completed here because if notification view is never selected by the user, the user would never know their un-read notification count.
            self.notificationCount = notifications.filter({!$0.isRead}).count
        }
        .onAppear {
            notificationVM.setDelegate(userModel)
        }
    }
}

struct ApplicationTabView_Previews: PreviewProvider {
    static var previews: some View {
        ApplicationTabView()
            .environmentObject(ReportsViewModel())
            .environmentObject(UserViewModel())
    }
}
