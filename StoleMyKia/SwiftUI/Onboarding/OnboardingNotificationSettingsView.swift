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
                Image(systemName: "globe.americas.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 45, height: 45)
                Text("Desired Location")
                    .font(.system(size: 25).weight(.heavy))
                Text("Stay up-to-date with reports happening within your neighborhood or city. Once you have a location, you can customize what report type you would like to notified through in-app and push notifications. Press 'Configure' to get started..")
                    .font(.system(size: 17))
            }
            Spacer()
            VStack(spacing: 12) {
                Button {
                    isShowingNotificationSettingsView.toggle()
                } label: {
                    Text("Configure")
                        .font(.system(size: 18.35).bold())
                        .padding()
                }
                NavigationLink {
                    OnboardingFinalView()
                        .onDisappear {
                            dismissOnboarding()
                        }
                } label: {
                    Text("Next")
                        .authButtonStyle(background: .blue)
                }
            }
            Spacer()
        }
        .padding()
        .overlay {
            if isLoading {
                FilmProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .multilineTextAlignment(.center)
        .navigationTitle("Desired Location")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isLoading)
        .hideNavigationTitle()
        .sheet(isPresented: $isShowingNotificationSettingsView) {
            NotificationSettingsView()
                .environmentObject(UserViewModel())
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
