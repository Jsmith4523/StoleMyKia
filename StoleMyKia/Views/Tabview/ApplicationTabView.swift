//
//  ApplicationTabView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/10/23.
//

import SwiftUI

enum ApplicationTabViewSelection {
    
    case feed, notification, user
    
    var title: String {
        switch self {
        case .feed:
            return "Feed"
        case .notification:
            return "Notifications"
        case .user:
            return "Account"
        }
    }
    
    var symbol: String {
        switch self {
        case .feed:
            return "tray"
        case .notification:
            return "bell"
        case .user:
            return "person.crop.circle"
        }
    }
    
    var tabItemLabel: some View {
        switch self {
        case .feed:
            return Label(self.title, systemImage: self.symbol)
        case .notification:
            return Label(self.title, systemImage: self.symbol)
        case .user:
            return Label(self.title, systemImage: self.symbol)
        }
    }
}

struct ApplicationTabView: View {
    
    @State private var selection: ApplicationTabViewSelection = .feed
    
    @StateObject private var reportsVM = ReportsViewModel()
    @EnvironmentObject var userModel: UserViewModel
        
    var body: some View {
        TabView(selection: $selection) {
            FeedView()
                .tag(ApplicationTabViewSelection.feed)
                .tabItem {
                    ApplicationTabViewSelection.feed.tabItemLabel
                }
            NotificationView()
                .tag(ApplicationTabViewSelection.notification)
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
        .tint(Color(uiColor: .label))
    }
}

struct ApplicationTabView_Previews: PreviewProvider {
    static var previews: some View {
        ApplicationTabView()
            .environmentObject(ReportsViewModel())
            .environmentObject(UserViewModel())
    }
}
