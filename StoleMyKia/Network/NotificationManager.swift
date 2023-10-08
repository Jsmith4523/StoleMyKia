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
    func fetchUserCurrentNotifications() async throws -> [AppUserNotification] {
        guard let currentUser = Auth.auth().currentUser else {
            throw NotificationManagerError.userError
        }
        
        let documents = try await Firestore.firestore()
            .collection(FirebaseDatabasesPaths.usersDatabasePath)
            .document(currentUser.uid)
            .collection(FirebaseDatabasesPaths.userNotificationPath)
            .limit(to: 10)
            .getDocuments()
            .documents
            
        do {
            let values = documents
                .map({$0.data()})
            
            var notifications = [AppUserNotification]()
            
            for value in values {
                let data = try JSONSerialization.data(withJSONObject: value)
                var notification = try JSONDecoder().decode(AppUserNotification.self, from: data)
                notifications.append(notification)
            }
            
            return notifications
        } catch {
            throw NotificationManagerError.codableError
        }
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
    func updateNotificationReadStatus(_ id: String) async throws {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        try await Firestore.firestore()
            .collection(FirebaseDatabasesPaths.usersDatabasePath)
            .document(currentUser.uid)
            .collection(FirebaseDatabasesPaths.userNotificationPath)
            .document(id)
            .updateData([AppUserNotification.isReadKey: true])
    }
    
    ///Checks firebase for number of unread notifications
    func fetchNumberOfUnreadNotifications() async -> Int  {
        guard let currentUser = Auth.auth().currentUser else { return 0 }
        
        do {
            let documents = try await Firestore.firestore()
                .collection(FirebaseDatabasesPaths.usersDatabasePath)
                .document(currentUser.uid)
                .collection(FirebaseDatabasesPaths.userNotificationPath)
                .whereFilter(.whereField(AppUserNotification.isReadKey, isEqualTo: false))
                .getDocuments()
            
            return documents.count
        } catch {
            return 0
        }
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
