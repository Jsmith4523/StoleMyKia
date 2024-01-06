//
//  NotificationManager.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 9/26/23.
//

import Foundation
import Firebase

final class NotificationManager {
    
    private enum NotificationManagerError: Error {
        case userError
        case listenerError
        case codableError
    }
    
    static let shared = NotificationManager()
    
    private static var listener: ListenerRegistration?
    
    private init() {}
        
    //MARK: Firestore Notification Methods
    
    /// Retrieve the current signed in users notifications
    /// - Returns: The users notifications.
    func fetchUserCurrentNotifications(notifications: [AppUserNotification]) async throws -> [AppUserNotification] {
        guard let currentUser = Auth.auth().currentUser else {
            throw NotificationManagerError.userError
        }
        
        let notifications = try await Firestore.firestore()
            .collection(FirebaseDatabasesPaths.usersDatabasePath)
            .document(currentUser.uid)
            .collection(FirebaseDatabasesPaths.userNotificationPath)
            .order(by: "dt", descending: true)
            .limit(to: notifications.isEmpty ? 5 : notifications.count)
            .getDocuments()
            .documents
            .map({$0.data()})
            .map({try JSONSerialization.data(withJSONObject: $0)})
            .map({try JSONDecoder().decode(AppUserNotification.self, from: $0)})
        
        return notifications
    }
    
    func fetchMoreNotifications(after notification: AppUserNotification) async throws -> [AppUserNotification] {
        guard let currentUser = Auth.auth().currentUser else {
            throw NotificationManagerError.userError
        }
        
        let notifications = try await Firestore.firestore()
            .collection(FirebaseDatabasesPaths.usersDatabasePath)
            .document(currentUser.uid)
            .collection(FirebaseDatabasesPaths.userNotificationPath)
            .order(by: "dt", descending: true)
            .start(after: [notification.dt])
            .limit(to: 5)
            .getDocuments()
            .documents
            .map({$0.data()})
            .map({try JSONSerialization.data(withJSONObject: $0)})
            .map({try JSONDecoder().decode(AppUserNotification.self, from: $0)})
        
        return notifications
    }
    
    ///Start listening for notifications for the current signed in user. Completion is fired when a new document is added, deleted, or modified.
    func listenForNotifications(completion: @escaping () -> ()) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let collection = Firestore.firestore()
            .collection(FirebaseDatabasesPaths.usersDatabasePath)
            .document(currentUser.uid)
            .collection(FirebaseDatabasesPaths.userNotificationPath)
        
        let listener = collection.addSnapshotListener { snapshot, err in
            guard let _ = snapshot, err == nil else { return }
            completion()
        }
        
        Self.listener = listener
    }
    
    /// Updates a notification document that a user has read.
    /// - Parameter id: The UUID of the notification
    func updateNotificationReadStatus(_ id: String) {
        Task {
            guard let currentUser = Auth.auth().currentUser else { return }
            
            try? await Firestore.firestore()
                .collection(FirebaseDatabasesPaths.usersDatabasePath)
                .document(currentUser.uid)
                .collection(FirebaseDatabasesPaths.userNotificationPath)
                .document(id)
                .updateData([AppUserNotification.isReadKey: true])
        }
    }
    
    ///Checks firebase for number of unread notifications
    func fetchNumberOfUnreadNotifications() async -> Int  {
        guard let currentUser = Auth.auth().currentUser else { return 0 }
        
        do {
            let queryCount = try await Firestore.firestore()
                .collection(FirebaseDatabasesPaths.usersDatabasePath)
                .document(currentUser.uid)
                .collection(FirebaseDatabasesPaths.userNotificationPath)
                .whereField("isRead", isEqualTo: false)
                .getDocuments()
                .documents
                .count
                        
            return queryCount
        } catch {
            return 0
        }
    }
    
    ///Delete a user's notification
    func deleteNotification(_ notification: AppUserNotification) async {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        try? await Firestore.firestore()
            .collection(FirebaseDatabasesPaths.usersDatabasePath)
            .document(currentUser.uid)
            .collection(FirebaseDatabasesPaths.userNotificationPath)
            .document(notification.id)
            .delete()
    }
    
    ///Remove the notification listener. This will be called when the instance class is deallocated.
    static func removeNotificationListener() {
        guard let listener else { return }
        listener.remove()
    }
    
    deinit {
        Self.removeNotificationListener()
    }
}
