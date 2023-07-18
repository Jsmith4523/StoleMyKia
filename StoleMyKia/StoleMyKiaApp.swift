//
//  StoleMyKiaApp.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/11/23.
//

import SwiftUI
import Firebase
import PartialSheet
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
        
        UITabBar.appearance().barTintColor = .systemBackground
        UINavigationBar.appearance().barTintColor = .systemBackground
        
        FirebaseApp.configure()
                
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { succes, err in
            guard succes, err == nil else  {
                return
            }
            
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Registered for remote notifications")
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register remote notification with error: \(error.localizedDescription)")
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    //Foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .list])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}
