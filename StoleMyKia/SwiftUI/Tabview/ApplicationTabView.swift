//
//  ApplicationTabView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/10/23.
//

import SwiftUI
import CoreLocation

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
            return "menucard"
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
    @EnvironmentObject var userVM: UserViewModel
        
    var body: some View {
        TabView(selection: $selection) {
            FeedView()
                .tag(ApplicationTabViewSelection.feed)
                .tabItem {
                    ApplicationTabViewSelection.feed.tabItemLabel
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
        .environmentObject(userVM)
        .environmentObject(notificationVM)
        .tint(Color(uiColor: .label))
        .onAppear {
            reportsVM.setFirebaseUserDelegate(userVM)
            notificationVM.setDelegate(userVM)
            CLLocationManager().requestAlwaysAuthorization()
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
