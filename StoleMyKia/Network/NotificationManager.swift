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
    
    private static var listener: ListenerRegistration?
        
    //MARK: Firestore Notification Methods
    
    /// Retrieve the current signed in users notifications
    /// - Returns: The users notifications.
    func fetchUserCurrentNotifications() async throws -> [Notification] {
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
            let data = try documents
                .compactMap({$0})
                .map({$0.data()})
                .map({try JSONSerialization.data(withJSONObject: $0)})
            let notifications = try data
                .map({try JSONDecoder().decode(Notification.self, from: $0)})
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
    func updateNotificationReadStatus(_ id: UUID) async throws {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        try await Firestore.firestore()
            .collection(FirebaseDatabasesPaths.usersDatabasePath)
            .document(currentUser.uid)
            .collection(FirebaseDatabasesPaths.userNotificationPath)
            .document(id.uuidString)
            .updateData([Notification.is    ReadKey: true])
    }
    
    ///Checks firebase for number of unread notifications
    func fetchNumberOfUnreadNotifications() async -> Int  {
        guard let currentUser = Auth.auth().currentUser else { return 0 }
        
        do {
            let count = try await Firestore.firestore()
                .collection(FirebaseDatabasesPaths.usersDatabasePath)
                .document(currentUser.uid)
                .collection(FirebaseDatabasesPaths.userNotificationPath)
                .whereField(Notification.isReadKey, isEqualTo: false)
                .getDocuments()
                .count
            return count
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
