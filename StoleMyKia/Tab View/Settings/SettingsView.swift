//
//  SettingsView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/13/23.
//

import SwiftUI

struct SettingsView: View {
    
    @State private var isShowingTwitterSupport = false
    @State private var isShowingPrivacyPolicy = false
    
    @EnvironmentObject var notificationModel: NotificationViewModel
    @EnvironmentObject var reportsModel: ReportsViewModel
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink {
                        NotificationSettingsView()
                    } label: {
                        Label("Notifications", systemImage: "app.badge")
                    }
                    NavigationLink {
                        MapSettingsView()
                    } label: {
                        Label("Map", systemImage: "map")
                    }
                } header: {
                    Text("Settings")
                }
                Section {
                    Button {
                        isShowingTwitterSupport.toggle()
                    } label: {
                       Label("Twitter Support", systemImage: "iphone.and.arrow.forward")
                    }
                    Button {
                        isShowingPrivacyPolicy.toggle()
                    } label: {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }
                    NavigationLink {
                        AboutAppView()
                    } label: {
                        Label("About this app", systemImage: "info.circle")
                    }
                } header: {
                    Text("Support")
                }
            }
            .navigationTitle("Settings")
        }
        .environmentObject(reportsModel)
        .environmentObject(notificationModel)
        .accentColor(.accentColor)
        .privacyPolicy(isPresented: $isShowingPrivacyPolicy)
        .twitterSupport(isPresented: $isShowingTwitterSupport)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .accentColor(.accentColor)
            .environmentObject(ReportsViewModel())
            .environmentObject(NotificationViewModel())
    }
}
