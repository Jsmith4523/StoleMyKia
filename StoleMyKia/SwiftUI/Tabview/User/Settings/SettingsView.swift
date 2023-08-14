//
//  SettingsView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/16/23.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var userVM: UserViewModel
    
    var body: some View {
        List {
            Section("Privacy & Safety") {
                Button {
                    
                } label: {
                    Label("About This App", systemImage: "info.circle")
                }
                Button {
                    
                } label: {
                    Label("Protect Yourself", systemImage: "shield")
                }
                Button {
                    
                } label: {
                    Label("Privacy Policy", systemImage: "hand.raised")
                }
            }
            Section("Support") {
                Button {
                    
                } label: {
                    Label("Email", systemImage: "envelope")
                }
                Button {
                    
                } label: {
                    Label("Report A Problem", systemImage: "exclamationmark.bubble")
                }
                Button {
                    
                } label: {
                    Label("Suggestion", systemImage: "lightbulb")
                }
            }
            Section {
                Button {
                    
                } label: {
                    Label("Sign Out", systemImage: "key.horizontal")
                }
                Button {
                    
                } label: {
                    Label("Delete My Account", systemImage: "trash")
                        .foregroundColor(.red)
                }
            } header: {
                Text("Authentication")
            } footer: {
                Text("Once you delete your account, all of your information and posts will be immediately removed..")
            }
        }
        .environmentObject(userVM)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
                .environmentObject(UserViewModel())
        }
    }
}
