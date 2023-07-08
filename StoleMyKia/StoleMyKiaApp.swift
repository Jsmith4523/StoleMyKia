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
    
    @StateObject private var userModel = UserViewModel()
    
    init() {
        
    }
        
    @UIApplicationDelegateAdaptor (AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ApplicationTabView()
                    .environmentObject(userModel)
            }
            .accentColor(Color(uiColor: .label))
            .onAppear {
                //Handling incoming notifications
                //appDelegate.firebaseUserDelegate(userModel)
                CLLocationManager().requestAlwaysAuthorization()
            }
        }
    }
}

//extension UIWindow {
//    
//    open override func didAddSubview(_ subview: UIView) {
//        if !(backgroundColor == nil) {
//            backgroundColor = UIColor(Color.brand)
//        } else {
//            backgroundColor = .clear
//        }
//    }
//}


class AppDelegate: UIScene, UIApplicationDelegate {
    
    weak private var firebaseUserDelegate: FirebaseUserDelegate?
    
    func firebaseUserDelegate(_ delegate: FirebaseUserDelegate) {
        self.firebaseUserDelegate = delegate
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        UITabBar.appearance().barTintColor = .systemBackground
        UINavigationBar.appearance().barTintColor = .systemBackground
        
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { succes, err in
            guard succes, err == nil else  {
                return
            }
        }
        
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let userDelegate = firebaseUserDelegate, let uid = userDelegate.uid else {
            return
        }
        
        //TODO: Notification Key and make sure backend object matches.
        guard let userInfo = userInfo as? FirebaseUserNotification else {
            //Handle notification error
            return
            
            
            //userDelegate.addRemoteNotification(userInfo)
            
            
            //Couple things need to done: convert the userInfo, find the radius, compare it to the currently logged in user notification radius,
            //Send it off to firebase if not greater than
            
        }
    }
}

//MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        messaging.token { token, err in
            guard !(token == nil), err == nil else {
                return
            }
        }
    }
}
