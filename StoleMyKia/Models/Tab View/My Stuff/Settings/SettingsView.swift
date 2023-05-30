//
//  SettingsView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/13/23.
//

import SwiftUI

struct SettingsView: View {
    
    @State private var isLoggingOut = false
    
    @State private var alertLogout = false
    @State private var alertDeletingAccount = false
    @State private var alertErrorLoggingOut = false
    @State private var alertErrorDeletingAccount = false
    
    @State private var isShowingTwitterSupport = false
    @State private var isShowingPrivacyPolicy = false
    
    @EnvironmentObject var userModel: UserViewModel
    @EnvironmentObject var notificationModel: NotificationViewModel
    @EnvironmentObject var reportsModel: ReportsViewModel
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Settings") {
                    NavigationLink {
                        NotificationSettingsView()
                    } label: {
                        Label("Notifications", systemImage: "app.badge")
                    }
//                    NavigationLink {
//                        MapSettingsView()
//                    } label: {
//                        Label("Map", systemImage: "map")
//                    }
                }
                Section("Support") {
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
                }
                Section("Account") {
                    Button {
                        alertLogout.toggle()
                    } label: {
                        Label("Log out", systemImage: "door.left.hand.open")
                    }
                    Button {
                        alertDeletingAccount.toggle()
                    } label: {
                        Label("Delete Account", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle(isLoggingOut ? "Logging out..." : "Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .interactiveDismissDisabled(isLoggingOut)
            .disabled(isLoggingOut)
        }
        .alert("Log out", isPresented: $alertLogout) {
            Button("Yes"){
                beginLoggingOut()
            }
            Button("Cancel"){}
        } message: {
            Text("Are you sure you wish to log out of your account?")
        }
        .alert("Delete Account", isPresented: $alertDeletingAccount) {
            Button("Yes, Delete Account", role: .destructive) {
                beginDeletingAccount()
            }
        } message: {
            Text("You are deleting your account. Once confirmed, all of your information will be deleted including reports you've made. Are you sure?")
        }
        .alert("Cannot delete account", isPresented: $alertErrorDeletingAccount) {
            Button("OK") {}
        } message: {
            Text("An error occurred when deleting your account. Please try again later")
        }
        .alert("Unable to log out", isPresented: $alertErrorLoggingOut) {
            Button("OK") {}
        } message: {
            Text("An error occurred when logging you out. Please try again later!")
        }
        .environmentObject(reportsModel)
        .environmentObject(notificationModel)
        .tint(.accentColor)
        .privacyPolicy(isPresented: $isShowingPrivacyPolicy)
        .twitterSupport(isPresented: $isShowingTwitterSupport)
    }
    
    private func beginDeletingAccount() {
        isLoggingOut = true
        userModel.deleteAccount { success in
            guard let success, success else {
                isLoggingOut = false
                alertErrorDeletingAccount.toggle()
                return 
            }
        }
    }
    
    private func beginLoggingOut() {
        dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.userModel.signOut { succes in
                guard succes else {
                    alertLogout.toggle()
                    isLoggingOut = false
                    return
                }
                dismiss()
            }
        }
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
