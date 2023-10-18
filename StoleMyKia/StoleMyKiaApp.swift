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
                        .tag("Auth")
                        .environmentObject(firebaseAuthModel)
                case .signedIn:
                    ApplicationRootView()
                        .tag("Signed In")
                        .environmentObject(firebaseAuthModel)
                case .loading:
                    ApplicationProgressView()
                        .tag("Loading")
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
        
        setContentNotificationCategory()
                
        UITabBar.appearance().barTintColor = .systemBackground
        UINavigationBar.appearance().barTintColor = .systemBackground
        
        UNUserNotificationCenter.current().delegate = self
                        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler(.noData)
        }
    }
    
    //Called when user selects a notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        guard Auth.auth().currentUser.isSignedIn else { return }
        
        let userInfo = response.notification.request.content.userInfo
        
        let rootVC = UIApplication.shared.windows.first?.rootViewController
        
        if let type = userInfo["notificationType"] as? String, let notificationType = AppUserNotification.UserNotificationType(rawValue: type), let id = userInfo["reportId"] as? String, let reportId = UUID.ID(uuidString: id) {
            
            var report: Report?
            
            Task {
                do {
                    let fetchedReport = try await ReportManager.manager.fetchSingleReport(reportId)
                    report = fetchedReport
                } catch {
                    let ac = UIAlertController(title: "Error", message: "There was an error presenting information for that notification.", preferredStyle: .alert)
                    ac.addAction(.init(title: "OK", style: .default))
                    ac.modalPresentationStyle = .overFullScreen
                    rootVC?.show(ac, sender: nil)
                }
                
                DispatchQueue.main.async {
                    if let report {
                        switch notificationType {
                        case .report:
                            let hostingController = UIHostingController(rootView: SelectedReportDetailView(reportId: report.id).environmentObject(ReportsViewModel()))
                            hostingController.modalPresentationStyle = .fullScreen
                            rootVC?.show(hostingController, sender: nil)
                        case .update:
                            let hostingController = UIHostingController(rootView: TimelineMapView(reportAssociatedId: report.role.associatedValue, dismissStyle: .dismiss))
                            hostingController.modalPresentationStyle = .fullScreen
                            rootVC?.show(hostingController, sender: nil)
                        case .falseReport:
                            //TODO: Show False Report Detail View
                            return
                        }
                    }
                }
            }
        }
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .banner, .sound, .list])
    }
    
    private func setContentNotificationCategory() {
        let updateNotificationCategory = UNNotificationCategory(identifier: "CONTENT", actions: [], intentIdentifiers: [], options: [])
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

