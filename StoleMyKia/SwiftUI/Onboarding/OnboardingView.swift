//
//  OnboardingView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/18/23.
//

import SwiftUI

struct OnboardingView: View {
        
    @EnvironmentObject var firebaseAuthVM: FirebaseAuthViewModel
    @StateObject private var onboardingVM = OnboardingViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                    .frame(height: 85)
                VStack {
                    VStack(spacing: 10) {
                        Image(systemName: "car.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 55, height: 55)
                        Text("Welcome to \(UIApplication.appName ?? "the application")!")
                            .font(.system(size: 25).weight(.heavy))
                        Text("\(UIApplication.appName ?? "This application") is the quickest and fastest way to stay notified of vehicle thefts and incidents within your community! Press 'Get Started' to begin customizing your experience.")
                            .font(.system(size: 17))
                    }
                    Spacer()
                    VStack(spacing: 10) {
                        NavigationLink {
                            OnboardingNotificationView()
                                .environmentObject(firebaseAuthVM)
                                .environmentObject(onboardingVM)
                        } label: {
                            Text("Get Started")
                                .authButtonStyle()
                        }
                    }
                    Spacer()
                }
                .padding()
            }
            .multilineTextAlignment(.center)
            .navigationTitle("Start")
            .navigationBarTitleDisplayMode(.inline)
            .hideNavigationTitle()
            .navigationBarBackButtonHidden(true)
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
           .environmentObject(FirebaseAuthViewModel())
    }
}
