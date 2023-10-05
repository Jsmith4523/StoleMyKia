//
//  ApplicationTabView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/10/23.
//

import SwiftUI
import CoreLocation

enum ApplicationTabViewSelection {
    
    case feed, notification, myStuff
    
    var title: String {
        switch self {
        case .feed:
            return "Reports"
        case .notification:
            return "Notifications"
        case .myStuff:
            return "My Stuff"
        }
    }
    
    var symbol: String {
        switch self {
        case .feed:
            return "menucard"
        case .notification:
            return "bell"
        case .myStuff:
            return "person.crop.circle"
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
            FeedView()
                .tag(ApplicationTabViewSelection.feed)
                .tabItem {
                    ApplicationTabViewSelection.feed.tabItemLabel
                }
            NotificationView()
                .tag(ApplicationTabViewSelection.notification)
                .badge(notificationCount ?? 0)
                .tabItem {
                    ApplicationTabViewSelection.notification.tabItemLabel
                }
            MyStuffView()
                .tag(ApplicationTabViewSelection.myStuff)
                .tabItem {
                    ApplicationTabViewSelection.myStuff.tabItemLabel
                }
        }
        .environmentObject(reportsVM)
        .environmentObject(userVM)
        .environmentObject(notificationVM)
        .tint(Color(uiColor: .label))
        .onReceive(notificationVM.$notificationUnreadQuantity) { quantity in
            self.notificationCount = quantity
        }
        .onAppear {
            if !(notificationCount.isNil()) {
                self.notificationVM.fetchNumberOfUnreadNotifications()
            }
        }
    }
}

struct ApplicationTabView_Previews: PreviewProvider {
    static var previews: some View {
        ApplicationTabView()
            .environmentObject(ReportsViewModel())
            .environmentObject(UserViewModel())
            //.preferredColorScheme(.dark)
    }
}
