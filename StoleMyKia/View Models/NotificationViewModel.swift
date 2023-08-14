//
//  NotificationViewModel.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/13/23.
//

import Foundation
import NotificationCenter
import Firebase
import MapKit
import SwiftUI

enum NotificationLoadStatus {
    case loading, loaded, empty, error
}

final class NotificationViewModel: NSObject, ObservableObject {
    
    enum NotificationType {
        case update(UUID)
        case other(UUID)
    }
    
    @Published private(set) var notifications: [Notification] = [
        .init(id: UUID(), dt: Date.now.epoch, title: "Update: Found", body: "A Update is available for your report regarding the Gray 2017 Hyundai Elantra", reportType: .stolen, reportId: UUID(), isRead: false, imageUrl: ""),
        .init(id: UUID(), dt: Date.now.epoch, title: "Update: Found", body: "A Update is available for your report regarding the Gray 2017 Hyundai Elantra", reportType: .stolen, reportId: UUID(), isRead: true, imageUrl: ""),
        .init(id: UUID(), dt: Date.now.epoch, title: "Update: Found", body: "A Update is available for your report regarding the Gray 2017 Hyundai Elantra", reportType: .stolen, reportId: UUID(), isRead: false, imageUrl: ""),
        .init(id: UUID(), dt: Date.now.epoch, title: "Update: Found", body: "A Update is available for your report regarding the Gray 2017 Hyundai Elantra", reportType: .stolen, reportId: UUID(), isRead: false, imageUrl: ""),
        .init(id: UUID(), dt: Date.now.epoch, title: "Update: Found", body: "A Update is available for your report regarding the Gray 2017 Hyundai Elantra", reportType: .stolen, reportId: UUID(), isRead: true, imageUrl: "")
    ]
    @Published private(set) var notificationLoadStatus: NotificationLoadStatus = .loading
        
    weak private var firebaseUserDelegate: FirebaseUserDelegate?
    
    private let db = Database.database()
    
    override init() {
        print("Alive: NotificationViewModel")
        super.init()
        
        UNUserNotificationCenter.current().delegate = self
        requestNotificationAuthorization()
    }
    
    func setDelegate(_ delegate: FirebaseUserDelegate) {
        self.firebaseUserDelegate = delegate
        self.saveFCMToken(delegate.uid)
    }
   
    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .criticalAlert]) { success, err in
            guard success, err == nil else {
                return
            }
            print("APNS Registered!")
        }
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func deleteNotification(_ type: NotificationType) {
        switch type {
        case .update(let id):
            notifications.removeAll(where: {$0.id == id})
        case .other:
            break
        }
    }
    
    deinit {
        self.firebaseUserDelegate = nil
        print("Dead: NotificationViewModel")
    }
}

//MARK: - UNUserNotificationCenterDelegate
extension NotificationViewModel: UNUserNotificationCenterDelegate {
    //Foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .banner, .list, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    private func saveFCMToken(_ uid: String?) {
        guard let uid else { return }
        guard let fcmToken = UserDefaults.standard.string(forKey: "fcmToken") else { return }
        var tokenDict = [String: Any]()
        tokenDict["token"] = fcmToken
        tokenDict["dt"] = Date.now.epoch
        db.reference(withPath: FirebaseDatabasesPaths.fcmTokenPath).child(uid).setValue(tokenDict)
        setupCriticalAlerts()
    }
    
    private func setupCriticalAlerts() {
        let updateNotificationCategory = UNNotificationCategory(identifier: "Update", actions: [], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([updateNotificationCategory])
    }
}
