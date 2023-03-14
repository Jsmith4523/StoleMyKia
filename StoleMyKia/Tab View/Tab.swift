//
//  ContentView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/11/23.
//

import SwiftUI

struct Tab: View {
    
    @EnvironmentObject var notificationModel: NotificationViewModel
    @EnvironmentObject var reportsModel: ReportsViewModel
    
    var body: some View {
        TabView {
            MapView()
                .tabItem {
                    Label("Reports", systemImage: "car.2.fill")
                }
            NotificationsView()
                .tabItem {
                    Label("Notifications", systemImage: "bell")
                }
            //TODO: Setup Notifications
                .badge(0)
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .accentColor(.red)
        .environmentObject(reportsModel)
        .environmentObject(notificationModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Tab()
            .environmentObject(ReportsViewModel())
            .environmentObject(NotificationViewModel())
    }
}
