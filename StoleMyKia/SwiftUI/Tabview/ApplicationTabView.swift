//
//  ApplicationTabView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/10/23.
//

import SwiftUI
import CoreLocation

enum ApplicationTabViewSelection {
    
    case feed, notification, myStuff, search
    
    var title: String {
        switch self {
        case .feed:
            return "Reports"
        case .notification:
            return "Notifications"
        case .myStuff:
            return "My Stuff"
        case .search:
            return "Search"
        }
    }
    
    var symbol: String {
        switch self {
        case .feed:
            return .reportSymbolName
        case .notification:
            return "bell"
        case .myStuff:
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
    
    @State private var notificationCount: Int?
    @State private var selection: ApplicationTabViewSelection = .feed
    
    @StateObject private var reportsVM = ReportsViewModel()
    @StateObject private var notificationVM = NotificationViewModel()
    @EnvironmentObject var userVM: UserViewModel
    
    var body: some View {
        TabView(selection: $selection) {
            FeedView(userVM: userVM, reportsVM: reportsVM)
                .tag(ApplicationTabViewSelection.feed)
                .tabItem {
                    ApplicationTabViewSelection.feed.tabItemLabel
                }
            SearchView(reportsVM: reportsVM, userVM: userVM)
                .tag(ApplicationTabViewSelection.search)
                .tabItem {
                    ApplicationTabViewSelection.search.tabItemLabel
                }
            NotificationView(notificationVM: notificationVM, reportsVM: reportsVM, userVM: userVM)
                .tag(ApplicationTabViewSelection.notification)
                .badge(notificationCount ?? 0)
                .tabItem {
                    ApplicationTabViewSelection.notification.tabItemLabel
                }
            MyStuffView(userVM: userVM, reportsVM: reportsVM)
                .tag(ApplicationTabViewSelection.myStuff)
                .tabItem {
                    ApplicationTabViewSelection.myStuff.tabItemLabel
                }
        }
        .tint(Color(uiColor: .label))
        .onReceive(notificationVM.$notificationUnreadQuantity) { quantity in
            self.notificationCount = quantity
        }
        .onAppear {
            if !(notificationCount.isNil()) {
                self.notificationVM.fetchNumberOfUnreadNotifications()
            }
        }
        .onAppear {
            CLLocationManager.shared.requestAlwaysAuthorization()
            UNUserNotificationCenter.current().requestAuthorization { _, _ in }
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
