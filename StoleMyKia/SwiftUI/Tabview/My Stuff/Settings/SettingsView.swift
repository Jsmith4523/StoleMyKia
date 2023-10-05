//
//  SettingsView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 9/20/23.
//

import SwiftUI

struct SettingsView: View {
    
    enum SettingsRoutes: Identifiable, CaseIterable {
        case notifications
        
        var id: Self {
            return self
        }
        
        var title: String {
            switch self {
            case .notifications:
                return "Notifications"
            }
        }
        
        var symbol: String {
            switch self {
            case .notifications:
                return ApplicationTabViewSelection.notification.symbol
            }
        }
    }
    
    @State private var isShowingNotificationSettingsView = false
    @State private var settingsRoute: SettingsRoutes?
    
    @EnvironmentObject var userVM: UserViewModel
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Preferences") {
                    ForEach(SettingsRoutes.allCases) { route in
                        Button {
                            self.settingsRoute = route
                        } label: {
                            Label(route.title, systemImage: route.symbol)
                        }
                    }
                }
                Section {
                    Button {
                        
                    } label: {
                        Label("Delete My Account", systemImage: "hammer")
                            .foregroundColor(.red)
                    }
                } header: {
                    Text("Permanent Actions")
                } footer: {
                    Text("All of your reports, updates, and settings will be removed once your account has been deleted. This is a permanent action and cannot be reversed.")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $settingsRoute) { route in
                switch route {
                case .notifications:
                    NotificationsView()
                        .environmentObject(userVM)
                }
            }
        }
        .tint(Color(uiColor: .label))
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(UserViewModel())
    }
}
