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
//                switch firebaseAuthModel.loginStatus {
//                case .signedOut:
//                    ApplicationAuthView()
//                case .signedIn:
                    ApplicationRootView()
                        .environmentObject(firebaseAuthModel)
                //}
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
        
        UNUserNotificationCenter.current().delegate = self
                        
        return true
    }
}

//MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Registered for remote notifications: \(deviceToken)")
        Messaging.messaging().apnsToken = deviceToken
    }
    
    //Foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .banner, .list, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}


