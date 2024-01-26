//
//  StoleMyKiaApp.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/11/23.
//

import SwiftUI
import Firebase
import UserNotifications
import FirebaseMessaging
import CoreLocation

@main
struct StoleMyKiaApp: App {
    
    @StateObject private var firebaseAuthVM = FirebaseAuthViewModel()
    @UIApplicationDelegateAdaptor (AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                switch firebaseAuthVM.loginStatus {
                case .signedOut:
                    ApplicationAuthView()
                        .tag("Auth")
                        .environmentObject(firebaseAuthVM)
                case .signedIn:
                    ApplicationRootView()
                        .tag("Signed In")
                        .environmentObject(firebaseAuthVM)
                case .loading:
                    ApplicationProgressView()
                        .tag("Loading")
                case .onboarding:
                    OnboardingView()
                        .tag("Onboarding")
                        .environmentObject(firebaseAuthVM)
                }
            }
            .accentColor(Color(uiColor: .label))
            .onAppear {
                print(FieldValue.serverTimestamp() as? TimeInterval)
            }
        }
    }
}
