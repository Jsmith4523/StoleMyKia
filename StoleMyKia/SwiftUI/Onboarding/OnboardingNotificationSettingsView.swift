//
//  OnboardingNotificationSettingsView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/18/23.
//

import SwiftUI

struct OnboardingNotificationSettingsView: View {
    
    @State private var isLoading = false
    @State private var alertErrorOnboarding = false
    
    @State private var isShowingNotificationSettingsView = false
    
    @EnvironmentObject var firebaseAuthVM: FirebaseAuthViewModel
    @EnvironmentObject var onboardingVM: OnboardingViewModel
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 85)
            VStack(spacing: 12) {
                Image(systemName: "mappin.and.ellipse")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 45, height: 45)
                Text("Location-Based Notifications and Reports Configuration")
                    .font(.system(size: 25).weight(.heavy))
                Text("Specify your preferred location for receiving notifications and reports from.")
            }
            Spacer()
            VStack(spacing: 6) {
                Button {
                    isShowingNotificationSettingsView.toggle()
                } label: {
                    Text("Configure")
                        .buttonStyle()
                }
                NavigationLink {
                    OnboardingInstructionsView()
                        .onDisappear {
                            dismissOnboarding()
                        }
                } label: {
                    Text("Continue")
                        .authButtonStyle(background: .blue)
                }
            }
            Spacer()
        }
        .padding()
        .multilineTextAlignment(.center)
        .sheet(isPresented: $isShowingNotificationSettingsView) {
            NotificationSettingsView()
                .environmentObject(UserViewModel())
        }
        .overlay {
            if isLoading {
                FilmProgressView()
            }
        }
        .alert("Verification Error", isPresented: $alertErrorOnboarding) {
            Button("OK") {}
        } message: {
            Text("Sorry, we ran into an issue verifying your account. Try again.")
        }
    }
    
    private func dismissOnboarding() {
        isLoading = true
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.5) {
            Task {
                do {
                    try await firebaseAuthVM.completeOnboarding()
                    isLoading = false
                } catch {
                    isLoading = false
                    alertErrorOnboarding.toggle()
                }
            }
        }
    }
}
