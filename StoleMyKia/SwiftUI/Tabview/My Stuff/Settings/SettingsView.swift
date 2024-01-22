//
//  SettingsView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 9/20/23.
//

import SwiftUI

struct SettingsView: View {
            
    enum SettingsRoutes: Identifiable, CaseIterable {
        static let preferencesRoutes: [Self] = [.notifications]
        
        static let supportRoutes: [Self] = [.email, .appIntroduction, .privacyPolicy, .termsOfUse, .disclaimer]
        
        case notifications
        case email
        case appIntroduction
        case privacyPolicy
        case termsOfUse
        case disclaimer
        
        var id: Self {
            return self
        }
        
        var title: String {
            switch self {
            case .notifications:
                return "Desired Location"
            case .email:
                return "Email Us"
            case .privacyPolicy:
                return "Privacy Policy"
            case .appIntroduction:
                return "How It Works"
            case .termsOfUse:
                return "Terms Of Use"
            case .disclaimer:
                return "Disclaimer"
            }
        }
        
        var symbol: String {
            switch self {
            case .notifications:
                return "globe.americas.fill"
            case .email:
                return "envelope"
            case .privacyPolicy:
                return "hand.raised"
            case .appIntroduction:
                return "book"
            case .termsOfUse:
                return "person"
            case .disclaimer:
                return "text.book.closed"
            }
        }
    }
    
    @State private var accountStatus = "Loading..."
    
    @State private var alertErrorDeletingAccount = false
    @State private var isLoading = false
    
    @State private var alertUserDeletingAccount = false
    
    @State private var isShowingBeSafeView = false
    @State private var isShowingNotificationSettingsView = false
    @State private var settingsRoute: SettingsRoutes?
    
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var authVM: FirebaseAuthViewModel
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Profile Details") {
                    LabeledContent("Phone Number", value: userVM.getAuthUserPhoneNumber() ?? "N/A")
                    LabeledContent("Account Status", value: self.accountStatus)
                }
                
                Section("About This App") {
                    LabeledContent("Name", value: UIApplication.appName ?? "N/A")
                    LabeledContent("Version No.", value: UIApplication.appVersion ?? "N/A")
                }
                
                Section("Preferences") {
                    ForEach(SettingsRoutes.preferencesRoutes) { route in
                        Button {
                            self.settingsRoute = route
                        } label: {
                            Label(route.title, systemImage: route.symbol)
                        }
                    }
                    Button {
                        URL.openApplicationSettings()
                    } label: {
                        Label("App Settings", systemImage: "iphone")
                    }
                }
                Section {
                    ForEach(SettingsRoutes.supportRoutes) { route in
                        Button {
                            self.settingsRoute = route
                        } label: {
                            Label(route.title, systemImage: route.symbol)
                        }
                    }
                } header: {
                    Text("Support and Legal")
                }

                Section {
                    Button {
                        alertUserDeletingAccount.toggle()
                    } label: {
                        Label("Delete My Account", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                } header: {
                    Text("Permanent Actions")
                } footer: {
                    Text("All of your information will be permanently deleted once approved. This is a permanent action and cannot be reversed. Continue at your own risk!")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $settingsRoute) { route in
                switch route {
                case .notifications:
                    NotificationSettingsView()
                        .environmentObject(userVM)
                case .email:
                    EmailComposeView(composeMode: .feature)
                        .canSendEmail()
                        .ignoresSafeArea()
                case .privacyPolicy:
                    PrivacyPolicyView()
                case .appIntroduction:
                    OnboardingInstructionsView()
                case .termsOfUse:
                    TermsOfServiceView()
                case .disclaimer:
                    DisclaimerView()
                }
            }
            .fullScreenCover(isPresented: $isShowingBeSafeView) {
                SafetyView()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Button {
                            isShowingBeSafeView.toggle()
                        } label: {
                            Image(systemName: "checkerboard.shield")
                                .foregroundColor(.green)
                        }
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
        .onAppear {
            getUserAccountStatus()
        }
    }
    
    private func getUserAccountStatus() {
        Task {
            let status = await userVM.getUserAccountStatus()
            self.accountStatus = status
        }
    }
    
    private func deleteAccount() {
        isLoading = true
        Task {
            do {
                try await authVM.permanentlyDeleteUser()
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
