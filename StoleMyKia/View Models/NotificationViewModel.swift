//
//  NotificationViewModel.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/13/23.
//

import Foundation
import NotificationCenter
import Firebase
import SwiftUI

enum NotificationLoadStatus {
    case loading, loaded, empty
}

@MainActor
final class NotificationViewModel: NSObject, ObservableObject {
    
    fileprivate enum NotificationType {
        case update(UUID)
        case other(UUID)
    }
    
    @Published private(set) var notificationUnreadQuantity = 0 {
        didSet {
            self.setApplicationBadgeCount(notificationUnreadQuantity)
        }
    }
    
    @Published private(set) var notifications: [Notification] = []
    @Published private(set) var loadStatus: NotificationLoadStatus = .loading
                        
    override init() {
        super.init()
        
        Messaging.messaging().delegate = self
        
        self.requestNotificationAuthorization()
        self.saveDeviceTokenToFirestore()
        self.listenForNewNotifications()
    }
   
    ///Request Notification Authorization from the user
    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .criticalAlert]) { success, err in
            guard success, err == nil else { return }
        }
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func userDidReadNotification(_ id: UUID) {
        Task {
            do {
                try await NotificationManager.shared.updateNotificationReadStatus(id)
                if let notificationIndex = notifications.firstIndex(where: {$0.id == id}) {
                    notifications[notificationIndex].isRead = true
                    if !(notificationUnreadQuantity == 0) {
                        notificationUnreadQuantity = notificationUnreadQuantity - 1
                    }
                }
            } catch {
                //TODO: Toast Banner
            }
        }
    }

    private func listenForNewNotifications() {
        NotificationManager.shared.listenForNotifications { [weak self] in
            self?.fetchNumberOfUnreadNotifications()
        }
    }
    
    func fetchNumberOfUnreadNotifications() {
        Task {
            let quantity = await NotificationManager.shared.fetchNumberOfUnreadNotifications()
            self.notificationUnreadQuantity = quantity
        }
    }
    
    func fetchNotifications() {
        Task {
            do {
                let notifications = try await NotificationManager.shared.fetchUserCurrentNotifications()
                self.notifications = notifications
                //Setting the application badge count to the number of unread notifications...
                let unreadNotificationQuantity = notifications.map({!($0.isRead)}).count
                self.notificationUnreadQuantity = unreadNotificationQuantity
                if notifications.isEmpty {
                    self.loadStatus = .empty
                } else {
                    self.loadStatus = .loaded
                }
            } catch {
                //TODO: Toast Banner
                if self.notifications.isEmpty {
                    self.loadStatus = .empty
                }
                print("Unable to retrieve users notification: \(error.localizedDescription)")
            }
        }
    }
    
    private func setApplicationBadgeCount(_ count: Int) {
        if #available(iOS 17.0, *) {
            UNUserNotificationCenter.current().setBadgeCount(count)
        } else {
            UIApplication.shared.applicationIconBadgeNumber = count
        }
    }
        
    deinit {
        print("Dead: NotificationViewModel")
    }
}

//MARK: - MessagingDelegate
extension NotificationViewModel: MessagingDelegate {
    private func saveDeviceTokenToFirestore(token: String? = nil) {
        Task {
            let savedToken = UserDefaults.standard.string(forKey: Constants.deviceToken)
            guard let token = token ?? savedToken, let _ = try? await UNUserNotificationCenter.current().requestAuthorization() else { return }
            UserDefaults.standard.setValue(token, forKey: Constants.deviceToken)
            let tokenDict = [Constants.deviceToken: token]
            NotificationCenter.default.post(name: .deviceFCMToken, object: nil, userInfo: tokenDict)
        }
    }
    
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        saveDeviceTokenToFirestore(token: fcmToken)
    }
}
