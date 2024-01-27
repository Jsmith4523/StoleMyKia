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
        Messaging.messaging().delegate = self
        
        setContentNotificationCategory()
                        
        UITabBar.appearance().barTintColor = .systemBackground
        UITabBar.appearance().shadowImage = nil
        //UINavigationBar.appearance().barTintColor = .systemBackground

        UNUserNotificationCenter.current().delegate = self
                        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler(.noData)
        }
        
        completionHandler(.newData)
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
        Self.deleteNotificationImageAttachment(response.notification)
        
        print(response.notification.request.content.attachments)
        let payload = response.notification.request.content.userInfo
        await handleNotificationPayload(for: payload)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .banner, .sound, .list])
    }
    
    private func setContentNotificationCategory() {
        let updateNotificationCategory = UNNotificationCategory(identifier: "MEDIA", actions: [], intentIdentifiers: [], options: [])
        
        //let mapNotificationAction      = UNNotificationAction(identifier: "change_notification_settiongs", title: "Modify Desired Location")
        let mapNotificationCategory    = UNNotificationCategory(identifier: "MAP", actions: [], intentIdentifiers: [], options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([updateNotificationCategory, mapNotificationCategory])
    }
}

//MARK: - Messaging Delegate
extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        //Saving the device token for later...
        if let fcmToken {
            UserDefaults.standard.set(fcmToken, forKey: Constants.deviceToken)
        }
    }
}

extension AppDelegate {
    
    private func handleNotificationPayload(for payload: [AnyHashable: Any]) async {
        guard let success = try? await FirebaseAuthManager.manager.userCanHandleNotification(), success else {
            return
        }
        
        let progressView = Self.createProgressView()
        let rootViewController = Self.selectedViewController()
        rootViewController?.present(progressView, animated: true) { [weak self] in
            guard let notificationType = payload["notificationType"] as? String, let reportId = payload["reportId"] as? String, let id = UUID(uuidString: reportId) else {
                progressView.dismiss(animated: true) {
                    self?.presentNotificationErrorAlert(on: rootViewController)
                }
                return
            }
            
            switch notificationType {
            case "Report":
                let hostingController = UIHostingController(rootView: ReportDetailView(reportId: id)
                    .environmentObject(ReportsViewModel())
                    .environmentObject(UserViewModel())
                )
                hostingController.view.tintColor = .label
                hostingController.modalPresentationStyle = .fullScreen
                progressView.dismiss(animated: true) {
                    rootViewController?.present(hostingController, animated: true)
                }
            case "Update":
                let hostingController = UIHostingController(rootView: TimelineMapView(reportAssociatedId: id, dismissStyle: .dismiss)
                    .environmentObject(ReportsViewModel())
                    .environmentObject(UserViewModel())
                )
                hostingController.view.tintColor = .label
                hostingController.modalPresentationStyle = .fullScreen
                progressView.dismiss(animated: true) {
                    rootViewController?.present(hostingController, animated: true)
                }
            default:
                progressView.dismiss(animated: true) {
                    self?.presentNotificationErrorAlert(on: rootViewController)
                }
            }
        }
    }
    
    private static func createProgressView() -> UIViewController {
        let viewController = UIViewController()
        let activityIndicator = UIActivityIndicatorView(style: .large)
        
        activityIndicator.color = .gray
        activityIndicator.startAnimating()
        
        viewController.view.backgroundColor = .systemBackground
        
        viewController.view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor)
        ])
        
        viewController.modalPresentationStyle = .fullScreen
        return viewController
    }
    
    private func presentNotificationErrorAlert(on viewController: UIViewController? = nil) {
        let ac = UIAlertController(title: "Error", message: "Sorry, we ran into a problem with this notification", preferredStyle: .alert)
        let primaryAction = UIAlertAction(title: "OK", style: .default)
        ac.addAction(primaryAction)
        
        guard let viewController = viewController ?? Self.rootViewController() else {
            return
        }
        
        viewController.present(ac, animated: true)
    }
    
    ///Access and returns the current selected view controller
    static func selectedViewController() -> UIViewController? {
        let keyWindow = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow
        
        //Checking if the view has a view controller presented
        //If not, immediately fall back to the root view controller
        guard let keyWindow, let viewController = keyWindow.rootViewController?.presentedViewController ?? keyWindow.rootViewController else {
            return nil
        }
        return viewController
    }
    
    ///Access and returns the current root view controller
    static func rootViewController() -> UIViewController? {
        let keyWindow = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow
        
        //Checking if the view has a view controller presented
        //If not, immediately fall back to the root view controller
        guard let keyWindow, let viewController = keyWindow.rootViewController?.presentedViewController else {
            return nil
        }
        return viewController
    }
    
    static func deleteNotificationImageAttachment(_ notification: UNNotification) {
        let category = notification.request.content.categoryIdentifier
        
        if (category == "MEDIA"),
           let attachment = notification.request.content.attachments.filter({$0.identifier == "image"}).first {
            
            let manager = FileManager.default
            let path = attachment.url.path()
            
            if manager.fileExists(atPath: path) {
                try? manager.removeItem(atPath: path)
            } 
            else if let imageURL = notification.request.content.userInfo["imageURL"] as? String {
                if !(UserDefaults.standard.value(forKey: imageURL) == nil) {
                    UserDefaults.standard.removeObject(forKey: imageURL)
                }
            }
        }
    }
}
