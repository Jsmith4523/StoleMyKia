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
                Text("Please enable notification services.")
            }
            Spacer()
            Group {
                switch onboardingVM.userLocationAuthStatus {
                case .authorized:
                    Text("Location Services Enabled!")
                case .disabled:
                    Text("Location Services Disabled!")
                case .notDetermined:
                    Text("Requesting...")
                case .error:
                    Text("There was an error location services authorization.")
                }
            }
            .font(.system(size: 16))
            .foregroundColor(.gray)
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
