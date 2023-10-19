//
//  OnboardingLocationView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/18/23.
//

import SwiftUI

struct OnboardingLocationView: View {
    
    @EnvironmentObject var firebaseAuthVM: FirebaseAuthViewModel
    @EnvironmentObject var onboardingVM: OnboardingViewModel
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 85)
            VStack(spacing: 12) {
                Image(systemName: "location.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 45, height: 45)
                Text("Enable Location Services")
                    .font(.system(size: 25).weight(.heavy))
                Text("When enabling notifications, you'll be receiving instant alerts about reports, updates, and more.")
            }
            Spacer()
            NavigationLink {
                OnboardingNotificationSettingsView()
                    .environmentObject(firebaseAuthVM)
                    .environmentObject(onboardingVM)
            } label: {
                Text("Continue")
                    .authButtonStyle()
            }
            Spacer()
        }
        .padding()
        .onAppear {
            onboardingVM.requestLocationServicesAccess()
        }
    }
}

struct OnboardingLocationView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingLocationView()
    }
}
