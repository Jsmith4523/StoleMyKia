//
//  UserAccountManager.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 5/7/23.
//

import Foundation
import Firebase

enum UserAccountManagerError: Error {
    case userIdError
    case reportDoesNotExist
    case bookmarksError
    case dataError
    case codableError
}

class UserAccountManager {
    
    ///The Logged in Auth user id
    private var uid: String?
    
    private let db = Database.database()
        
    private var reference: DatabaseReference {
        db.reference(withPath: FirebaseDatabasesPaths.usersDatabasePath)
    }
    
    /// Fetch the signed in users information.
    /// - Parameter uid: The Auth user uid.
    func fetchSignedInUserInformation(uid: String) async throws -> FirebaseUser {
        guard let data = try await reference.child(uid).getData().value else {
            throw UserAccountManagerError.dataError
        }
        
        guard let firebaseUser = JSONSerialization.objectFromData(FirebaseUser.self, jsonObject: data) else {
            throw UserAccountManagerError.codableError
        }
        
        self.uid = uid
        
        return firebaseUser
    }
    
    /// Adds a report UUID to the user's bookmarks.
    /// - Parameters:
    ///   - reportId: The UUID of the report the user is bookmarking.
    func addBookmark(reportId: UUID) async throws {
        guard let uid else {
            throw UserAccountManagerError.userIdError
        }
        
        guard try await ReportManager.manager.reportDoesExist(reportId) else {
            throw UserAccountManagerError.reportDoesNotExist
        }
        
        let userBookmarkReference = reference.child(uid).child(FirebaseDatabasesPaths.userBookmarksPath)
        let currentBookmarks = try await getUserCurrentBookmarks()
        
        var bookmarks = currentBookmarks
        bookmarks.append(reportId)
        
        try await userBookmarkReference.setValue(bookmarks)
    }
    
    /// Removes a users bookmarked report.
    /// - Parameter reportId: The UUID of the report the user wants to no longer bookmark.
    func removeBookmark(reportId: UUID) async throws {
        guard let uid else {
            throw UserAccountManagerError.userIdError
        }
        
        let userBookmarkReference = reference.child(uid).child(FirebaseDatabasesPaths.userBookmarksPath)
        let currentBookmarks = try await getUserCurrentBookmarks()
        
        guard let bookmarkIndex = currentBookmarks.firstIndex(of: reportId) else { return }
        var bookmarks = currentBookmarks
        
        bookmarks.remove(at: bookmarkIndex)
        
        try await userBookmarkReference.setValue(bookmarks)
    }
    
    /// Retrives the signed in users current bookmarks.
    /// - Returns: The array of the user's bookmarked reports by UUIDs.
    func getUserCurrentBookmarks() async throws -> [UUID] {
        guard let uid else {
            throw UserAccountManagerError.userIdError
        }
        
        let userBookmarkReference = reference.child(uid).child(FirebaseDatabasesPaths.userBookmarksPath)
        
        guard let currentBookmarks = try await userBookmarkReference.getData().value as? [UUID] else {
            throw UserAccountManagerError.bookmarksError
        }
        
        return currentBookmarks
    }
    
    /// Checks if a report is bookmarked.
    /// - Parameter reportId: The UUID of the report.
    /// - Returns: Bool deterimining if the users has this report bookmarked.
    func isBookmarked(_ reportId: UUID) async throws -> Bool {
        guard let uid else {
            throw UserAccountManagerError.userIdError
        }
        
        let userBookmarks = try await getUserCurrentBookmarks()
        guard userBookmarks.contains(where: {$0 == reportId}) else { return false }
        
        return true
    }
    
    /// Sets the Auth user uid to nil
    func userIsSigningOut() {
        self.uid = nil
    }
}
