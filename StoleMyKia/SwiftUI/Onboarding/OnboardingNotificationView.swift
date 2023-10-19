//
//  OnboardingNotificationView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/18/23.
//

import SwiftUI

struct OnboardingNotificationView: View {
    
    @EnvironmentObject var firebaseAuthVM: FirebaseAuthViewModel
    @EnvironmentObject var onboardingVM: OnboardingViewModel

    var body: some View {
        VStack {
            Spacer()
                .frame(height: 85)
            VStack(spacing: 12) {
                Image(systemName: "bell.badge")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 45, height: 45)
                Text("Enable Notifications")
                    .font(.system(size: 25).weight(.heavy))
                Text("When enabling notifications, you'll be receiving instant alerts about reports, updates, and more.")
            }
            Spacer()
            NavigationLink {
                OnboardingLocationView()
                    .environmentObject(firebaseAuthVM)
                    .environmentObject(onboardingVM)
            } label: {
                Text("Continue")
                    .authButtonStyle()
            }
            Spacer()
        }
        .padding()
        .multilineTextAlignment(.center)
        .onAppear {
            onboardingVM.requestNotificationAccess()
        }
    }
}

struct OnboardingNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingNotificationView()
    }
}
