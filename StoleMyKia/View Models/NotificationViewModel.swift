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
    
    func setDelegate(_ delegate: FirebaseUserDelegate) {
        self.firebaseUserDelegate = delegate
        fetchFirebaseUserNotifications()
        beginListeningForNotifications()
    }
        
    override init() {
        super.init()
    }
    
    func requestNotificationCenterAccess() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .criticalAlert]) { success, err in
            guard success, err == nil else {
                return
            }
        }
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
                let notifications = try JSONSerialization.objectsFromFoundationObjects(data, to: FirebaseNotification.self)
                DispatchQueue.main.async {
                    self.userNotifications = notifications
                    self.notificationLoadStatus = .loaded
                }
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
