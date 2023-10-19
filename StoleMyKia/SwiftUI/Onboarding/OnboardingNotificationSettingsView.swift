//
//  OnboardingNotificationSettingsView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/18/23.
//

import SwiftUI

struct OnboardingNotificationSettingsView: View {
    
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
                Text("Location-based notificaitons")
                    .font(.system(size: 25).weight(.heavy))
                Text("Setup where and what you would like to receive notifications on.")
            }
            Spacer()
            
            VStack(spacing: 10) {
                Button {
                    isShowingNotificationSettingsView.toggle()
                } label: {
                    Text("Configure")
                        .authButtonStyle(background: .blue)
                }
            }
            Spacer()
        }
        .padding()
        .multilineTextAlignment(.center)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink("Skip") {
                    
                }
            }
        }
        .sheet(isPresented: $isShowingNotificationSettingsView) {
            NotificationSettingsView()
                .environmentObject(UserViewModel())
        }
    }
}

struct OnboardingNotificationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OnboardingNotificationSettingsView()
        }
    }
}
