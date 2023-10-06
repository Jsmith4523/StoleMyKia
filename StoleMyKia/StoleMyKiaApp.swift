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
                case .loading:
                    ApplicationProgressView()
                }
            }
            .accentColor(Color(uiColor: .label))
        }
    }
}

class AppDelegate: UIScene, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        
        Firestore.firestore().settings = settings
        
        setupUpdateCriticalAlert()
                
        UITabBar.appearance().barTintColor = .systemBackground
        UINavigationBar.appearance().barTintColor = .systemBackground
        
        UNUserNotificationCenter.current().delegate = self
                        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler(.noData)
        }
        
        guard Auth.auth().currentUser.isSignedIn else { return }
        
        if let rootVC = window?.rootViewController {
            let vc = UIViewController()
            vc.view.backgroundColor = .orange
            rootVC.present(vc, animated: true)
        }
    }
    
    private func setupUpdateCriticalAlert() {
        let updateNotificationCategory = UNNotificationCategory(identifier: "UPDATE", actions: [], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([updateNotificationCategory])
    }
}

//MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Registered for remote notifications: \(deviceToken)")
        Messaging.messaging().apnsToken = deviceToken
    }
}

