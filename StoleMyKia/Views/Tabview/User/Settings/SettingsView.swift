//
//  SettingsView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/16/23.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var userModel: UserViewModel
    @EnvironmentObject var reportsModel: ReportsViewModel
    
    var body: some View {
        NavigationView {
            List {
                Section("Account") {
                    NavigationLink {
                        
                    } label: {
                        Label("My Account", systemImage: ApplicationTabViewSelection.user.symbol)
                    }
                }
                
                Section("Notifications") {
                    NavigationLink {
                        
                    } label: {
                        Label("Notifications", systemImage: ApplicationTabViewSelection.notification.symbol)
                    }
                }
                
                Section("Support") {
                    Button {
                        
                    } label: {
                        Label("Twitter", systemImage: "bird")
                    }
                    Button {
                        
                    } label: {
                        Label("Email", systemImage: "envelope")
                    }
                }
                
                Section("More") {
                    NavigationLink {
                        
                    } label: {
                        Label("About", systemImage: "app")
                    }
                    Button {
                        
                    } label: {
                        Label("Open Application Settings", systemImage: "gearshape")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .presentationDragIndicator(.visible)
        }
        .tint(Color(uiColor: .label))
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
