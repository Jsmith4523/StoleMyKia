//
//  UserAccountManager.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 5/7/23.
//

import Foundation
import Firebase


@MainActor
class FirebaseUserManager {
    
    enum FirebaseUserManagerError: Error {
        case userError
        case userSettingsError
        case doesNotExist
        case reportDoesNotExist
        case bookmarksError
        case dataError
        case codableError
    }

    private let collection = Firestore.firestore()
        
    //MARK: - User Settings Methods
    
    /// Retrieve the current logged in user notification settings
    /// - Returns: The users notification settings
    func fetchUserNotificationSettings() async throws -> UserNotificationSettings {
        guard let currentUser = Auth.auth().currentUser else {
            throw FirebaseUserManagerError.userError
        }
        
        let value = try await Firestore.firestore()
            .collection(FirebaseDatabasesPaths.usersDatabasePath)
            .document(currentUser.uid)
            .collection(FirebaseDatabasesPaths.userSettingsPath)
            .document(FirebaseDatabasesPaths.userNotificationSettings)
            .getDocument()
            .data()
        
        guard let value else {
            throw FirebaseUserManagerError.userSettingsError
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: value)
            let settings = try JSONDecoder().decode(UserNotificationSettings.self, from: data)
            return settings
        } catch {
            throw FirebaseUserManagerError.codableError
        }
    }
    
    
    func saveUserNotificationSettings(_ settings: UserNotificationSettings) async throws {
        guard let currentUser = Auth.auth().currentUser else {
            throw FirebaseUserManagerError.userError
        }
        
        do {
            let data = try JSONEncoder().encode(settings)
            let value = try JSONSerialization.jsonObject(with: data)
            
            guard let value = value as? [String: Any] else {
                throw FirebaseUserManagerError.codableError
            }
            
            try await Firestore.firestore()
                .collection(FirebaseDatabasesPaths.usersDatabasePath)
                .document(currentUser.uid)
                .collection(FirebaseDatabasesPaths.userSettingsPath)
                .document(FirebaseDatabasesPaths.userNotificationSettings)
                .setData(value, merge: true)
            
        } catch {
            throw FirebaseUserManagerError.codableError
        }
    }
    
    
    //MARK: - User Reports and Bookmarks Methods
    
    ///Fetch the current signed in user reports.
    /// - Returns: The users reports.
    func fetchUserReports() async throws -> [Report] {
        guard let currentUser = Auth.auth().currentUser else {
            throw FirebaseUserManagerError.userError
        }
        
        let documents = try await Firestore.firestore()
            .collection(FirebaseDatabasesPaths.reportsDatabasePath)
            .whereField("uid", isEqualTo: currentUser.uid)
            .getDocuments()
            .documents
        
        guard let data = try? documents.map({$0.data()}).map({try JSONSerialization.data(withJSONObject: $0)}) else {
            throw FirebaseUserManagerError.dataError
        }
        
        guard let reports = try? data.compactMap({$0}).map({try JSONDecoder().decode(Report.self, from: $0)}) else {
            throw FirebaseUserManagerError.codableError
        }
        
        return reports
    }
    
    ///Fetch the current signed in user bookmarks.
    /// - Returns: The users bookmarked reports.
    func fetchUserBookmarks() async throws -> [Report] {
        guard let currentUser = Auth.auth().currentUser else {
            throw FirebaseUserManagerError.userError
        }
        
        let documents = try await Firestore.firestore()
            .collection(FirebaseDatabasesPaths.usersDatabasePath)
            .document(currentUser.uid)
            .collection(FirebaseDatabasesPaths.userBookmarksPath)
            .getDocuments()
            .documents
        
        guard let data = try? documents.map({$0.data()}).map({try JSONSerialization.data(withJSONObject: $0)}) else {
            throw FirebaseUserManagerError.dataError
        }
        
        guard let reports = try? data.compactMap({$0}).map({try JSONDecoder().decode(Report.self, from: $0)}) else {
            throw FirebaseUserManagerError.codableError
        }
        
        return reports
    }
    
    static func bookmarkReport(_ id: UUID) async throws {
        guard let currentUser = Auth.auth().currentUser else {
            throw FirebaseUserManagerError.userError
        }
        
        guard try await ReportManager.manager.reportDoesExist(id) else {
            throw FirebaseUserManagerError.reportDoesNotExist
        }
        
        do {
            var info = [String: Any]()
            info["id"] = id.uuidString
            
            try await Firestore.firestore()
                .collection(FirebaseDatabasesPaths.usersDatabasePath)
                .document(currentUser.uid)
                .collection(FirebaseDatabasesPaths.userBookmarksPath)
                .document(id.uuidString)
                .setData(info)
        } catch {
            throw FirebaseUserManagerError.bookmarksError
        }
    }
    
    static func userHasBookmarkedReport(_ id: UUID) async -> Bool {
        guard let currentUser = Auth.auth().currentUser else {
            return false
        }
        
        do {
            let document = try await Firestore.firestore()
                .collection(FirebaseDatabasesPaths.usersDatabasePath)
                .document(currentUser.uid)
                .collection(FirebaseDatabasesPaths.userBookmarksPath)
                .document(id.uuidString)
                .getDocument()
            return document.exists
        } catch {
            return false
        }
    }
    
    static func undoBookmark(_ id: UUID) async throws {
        guard let currentUser = Auth.auth().currentUser else {
            throw FirebaseUserManagerError.userError
        }
        
        try? await Firestore.firestore()
            .collection(FirebaseDatabasesPaths.usersDatabasePath)
            .document(currentUser.uid)
            .collection(FirebaseDatabasesPaths.userBookmarksPath)
            .document(id.uuidString)
            .delete()
    }
    
    //MARK: - FCM Token Methods
    
    ///Deletes the messaging token for the current users device that they are signing out of.
    static func deleteFCMToken(_ uid: String?) {
        guard let uid else { return }
        
        if let deviceID = UserDefaults.standard.string(forKey: Constants.deviceIDKey) {
            Firestore.firestore()
                .collection(FirebaseDatabasesPaths.usersDatabasePath)
                .document(uid)
                .collection(FirebaseDatabasesPaths.fcmTokenPath)
                .document(deviceID)
                .delete()
        }
    }
    
    /// Saves the device FCM Token
    /// - Parameter info: Information regarding the device the user has signed into or enabled push notifications for.
    static func saveFCMTOken(info: [String: Any]) {
        let deviceID = info[Constants.deviceIDKey] as! String
        
        guard let user = Auth.auth().currentUser else { return }
        let uid = user.uid
        Firestore.firestore()
            .collection(FirebaseDatabasesPaths.usersDatabasePath)
            .document(uid)
            .collection(FirebaseDatabasesPaths.fcmTokenPath)
            .document(deviceID)
            .setData(info)
    }
        
    deinit {
        print("Dead: FirebaseUserManager")
    }
}
