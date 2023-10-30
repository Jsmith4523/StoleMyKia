//
//  AppDelegate.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/23/23.
//

import Foundation
import UIKit
import SwiftUI
import Firebase

class AppDelegate: UIScene, UIApplicationDelegate {
        
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        
        Firestore.firestore().settings = settings
        
        setContentNotificationCategory()
                
        UITabBar.appearance().barTintColor = .systemBackground
        UINavigationBar.appearance().barTintColor = .systemBackground
        UITabBarItem.appearance().badgeColor = UIColor(Color.brand)

        UNUserNotificationCenter.current().delegate = self
                        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler(.noData)
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Registered for remote notifications: \(deviceToken)")
        Messaging.messaging().apnsToken = deviceToken
    }
}

//MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        guard Auth.auth().currentUser.isSignedIn else { return }
        
        let userInfo = response.notification.request.content.userInfo
        let rootVC = UIApplication.shared.windows.first?.rootViewController
        
        rootVC?.dismiss(animated: true)
        
        do {
            guard let notificationType = AppUserNotification.UserNotificationType(rawValue: userInfo["notificationType"] as! String), let reportId = UUID.ID(uuidString: userInfo["reportId"] as! String), let report = try await ReportManager.manager.fetchSingleReport(reportId), report.belongsToUser else {
                throw FirebaseAuthManager.FirebaseAuthManagerError.specificError("Notification does not belong to current logged in user")
            }
                        
            DispatchQueue.main.async {
                switch notificationType {
                case .report:
                    let hostingController = UIHostingController(rootView: ReportDetailView(reportId: report.id).environmentObject(ReportsViewModel()))
                    hostingController.modalPresentationStyle = .fullScreen
                    rootVC?.show(hostingController, sender: nil)
                case .update:
                    let hostingController = UIHostingController(rootView: TimelineMapView(reportAssociatedId: report.role.associatedValue, dismissStyle: .dismiss))
                    hostingController.modalPresentationStyle = .fullScreen
                    rootVC?.show(hostingController, sender: nil)
                case .falseReport:
                    let hostingController = UIHostingController(rootView: FalseReportDetailView(reportId: report.id))
                    hostingController.modalPresentationStyle = .fullScreen
                    rootVC?.show(hostingController, sender: nil)
                }
            }
        } catch {
            presentNotificationError()
        }
        
        func presentNotificationError() {
            let ac = UIAlertController(title: "Error", message: "There was an error presenting information for that notification.", preferredStyle: .alert)
            ac.addAction(.init(title: "OK", style: .default))
            ac.modalPresentationStyle = .overFullScreen
            rootVC?.show(ac, sender: nil)
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .banner, .sound, .list])
    }
    
    private func setContentNotificationCategory() {
        let updateNotificationCategory = UNNotificationCategory(identifier: "CONTENT", actions: [], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([updateNotificationCategory])
    }
}
