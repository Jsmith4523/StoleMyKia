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
import MapKit

@main
struct StoleMyKiaApp: App {
    
    @StateObject private var firebaseAuthModel = FirebaseAuthViewModel()
    @UIApplicationDelegateAdaptor (AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                switch firebaseAuthModel.loginStatus {
                case .signedOut:
                    ApplicationAuthView()
                        .environmentObject(firebaseAuthModel)
                case .signedIn:
                    ApplicationRootView()
                        .environmentObject(firebaseAuthModel)
                }
            }
            .accentColor(Color(uiColor: .label))
        }
    }
}

class AppDelegate: UIScene, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        UITabBar.appearance().barTintColor = .systemBackground
        UINavigationBar.appearance().barTintColor = .systemBackground
        
        Messaging.messaging().delegate = self
        
        UNUserNotificationCenter.current().delegate = self
                        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if Auth.auth().canHandleNotification(userInfo) {
            print(userInfo.values)
            completionHandler(.noData)
        }
    }
}

//MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Registered for remote notifications: \(deviceToken)")
        Messaging.messaging().apnsToken = deviceToken
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        UserDefaults.standard.setValue(fcmToken, forKey: "fcmToken")
        print("APNS Token saved for later")
    }
}


