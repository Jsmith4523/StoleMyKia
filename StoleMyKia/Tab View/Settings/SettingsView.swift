//
//  SettingsView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/13/23.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var notificationModel: NotificationViewModel
    @EnvironmentObject var reportsModel: ReportsViewModel
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink {
                    NotificationSettingsView()
                } label: {
                    Label("Notifications", systemImage: "app.badge")
                }
            }
            .navigationTitle("Settings")
        }
        .environmentObject(reportsModel)
        .environmentObject(notificationModel)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .accentColor(.red)
            .environmentObject(ReportsViewModel())
    }
}
