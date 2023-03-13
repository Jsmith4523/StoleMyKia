//
//  SettingsView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/13/23.
//

import SwiftUI

struct SettingsView: View {
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
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .accentColor(.red)
            .environmentObject(ReportsViewModel())
    }
}
