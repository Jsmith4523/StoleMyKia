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
    case loading, loaded
}

final class NotificationViewModel: NSObject, ObservableObject {
    
    enum NotificationError: Error {
        case snapshotError
    }
    
    @Published private(set) var userNotifications: [FirebaseNotification] = []
    @Published private(set) var notificationLoadStatus: NotificationLoadStatus = .loading
        
    weak private var firebaseUserDelegate: FirebaseUserDelegate?
    
    private let db = Database.database()
    
    private lazy var reference: DatabaseReference = {
        guard let uid = firebaseUserDelegate?.uid else { fatalError("FirebaseUserDelegate was not set!") }
        return db.reference(withPath: FirebaseDatabasesPaths.userNotificationDatabasePath).child(uid)
    }()
    
    private var fcmTokenRef: DatabaseReference {
        return db.reference(withPath: FirebaseDatabasesPaths.fcmTokenPath)
    }
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func setDelegate(_ delegate: FirebaseUserDelegate) {
        self.firebaseUserDelegate = delegate
        print(delegate.uid)
        self.setFcmToken(firebaseUserDelegate?.uid)
    }
    
    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .carPlay, .timeSensitive]) { success, err in
            guard success, err == nil else {
                return
            }
            print("APNS Registered!")
        }
        
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    ///Begin observing when a notification object is added to the reference.
    private func beginListeningForNotifications() {
        reference.observe(.childAdded) { [weak self] snapshot in
            //Fetching all notifications from reference...
            self?.fetchFirebaseUserNotifications()
        }
    }
    
    ///Fetched the logged in Firebase User notifications
    func fetchFirebaseUserNotifications() {
        Task {
            do {
                let snapshot = try await self.reference.getData()
                guard let data = snapshot.value else { throw NotificationError.snapshotError }
//                let notifications = try JSONSerialization.objectsFromFoundationObjects(data, to: FirebaseNotification.self)
//                DispatchQueue.main.async {
//                    self.userNotifications = notifications
//                    self.notificationLoadStatus = .loaded
//                }
            } catch {
                DispatchQueue.main.async {
                    self.userNotifications = .dummyNotifications()
                    self.notificationLoadStatus = .loaded
                }
            }
        }
    }
    
    /// Updates the 'isRead' member value of a selected FirebaseNotification Object.
    /// - Parameters:
    ///   - id: The UUID of the objet.
    ///   - didRead: The bool value.
    func updateNotificationStatus(id: UUID, didRead: Bool = true) async {
        do {
            try await reference.updateChildValues([FirebaseNotification.isRead: didRead])
            guard let index = userNotifications.firstIndex(where: {$0.id == id}) else { return }
            userNotifications[index].isRead = didRead
        } catch {
            print(error.localizedDescription)
        }
    }
    
    deinit {
        self.firebaseUserDelegate = nil
        print("Dead: NotificationViewModel")
    }
}

extension NotificationViewModel: UNUserNotificationCenterDelegate {
    //Foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .banner, .list, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(response.notification.request.content.userInfo)
        completionHandler()
    }
    
    private func setFcmToken(_ uid: String?) {
        guard let uid else { return }
        guard let fcmToken = UserDefaults.standard.string(forKey: "fcmToken") else { return }
        var tokenDict = [String: Any]()
        tokenDict["token"] = fcmToken
        tokenDict["dt"] = Date.now.epoch
        fcmTokenRef.child(uid).setValue(tokenDict)
    }
}
