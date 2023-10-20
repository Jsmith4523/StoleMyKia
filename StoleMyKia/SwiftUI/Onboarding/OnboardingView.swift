//
//  OnboardingView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/18/23.
//

import SwiftUI

struct OnboardingView: View {
    
    @State private var alertSkippingOnboarding = false
    
    @EnvironmentObject var firebaseAuthVM: FirebaseAuthViewModel
    @StateObject private var onboardingVM = OnboardingViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                    .frame(height: 85)
                VStack {
                    VStack(spacing: 10) {
                        Image(systemName: "person.3.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 75, height: 75)
                        Text("Thanks for using \(UIApplication.appName ?? "the application")!")
                            .font(.system(size: 25).weight(.heavy))
                        Text("Before you begin, we want to ensure you're receiving the best experience when using the application.")
                            .font(.system(size: 17))
                    }
                    Spacer()
                    VStack(spacing: 10) {
                        NavigationLink {
                            OnboardingNotificationView()
                                .environmentObject(firebaseAuthVM)
                                .environmentObject(onboardingVM)
                        } label: {
                            Text("Continue")
                                .authButtonStyle()
                        }
                    }
                    Spacer()
                }
                .padding()
            }
            .multilineTextAlignment(.center)
            .navigationBarBackButtonHidden(true)
            .alert("Skip Onboarding?", isPresented: $alertSkippingOnboarding) {
                Button("Skip") { }
                Button("Cancel") { }
            } message: {
                Text("We want to ensure you're receiving the best experience with \(UIApplication.appName ?? "using the application"). Are you sure?")
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
           // .environmentObject(FirebaseAuthViewModel())
    }
}
