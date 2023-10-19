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
    
    @State private var alertErrorDeletingAccount = false
    @State private var isLoading = false
    
    @State private var alertUserDeletingAccount = false
    
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
                        alertUserDeletingAccount.toggle()
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
                    NotificationSettingsView()
                        .environmentObject(userVM)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isLoading {
                        ProgressView()
                    }
                }
            }
        }
        .disabled(isLoading)
        .interactiveDismissDisabled(isLoading)
        .tint(Color(uiColor: .label))
        .alert("Delete Your Account?", isPresented: $alertUserDeletingAccount) {
            Button("Yes, Delete My Account", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("""
                 When choosing to delete your account, any bookmarks, reports, and settings you have made will be permanently deleted.
                 This decision cannot be reversed. Are you sure?
                 """)
        }
        .alert("Error", isPresented: $alertErrorDeletingAccount) {
            Button("OK") {}
        } message: {
            Text("An error occurred during the deletion process. Please try again.")
        }
    }
    
    private func deleteAccount() {
        isLoading = true
        Task {
            do {
                try await userVM.deleteUserAccount()
                dismiss()
                isLoading = false
            } catch {
                isLoading = false
                alertErrorDeletingAccount = true
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(UserViewModel())
    }
}
