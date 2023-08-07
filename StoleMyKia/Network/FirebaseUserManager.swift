//
//  UserAccountManager.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 5/7/23.
//

import Foundation
import Firebase

enum FirebaseUserManagerError: Error {
    case userIdError
    case doesNotExist
    case reportDoesNotExist
    case bookmarksError
    case dataError
    case codableError
}

class FirebaseUserManager {
    
    private let db = Database.database()
    private let fs = Firestore.firestore()
    
    private weak var firebaseUserDelegate: FirebaseUserDelegate?

    private var userUid: String? {
        firebaseUserDelegate?.uid
    }
        
    private var reference: DatabaseReference {
        db.reference(withPath: FirebaseDatabasesPaths.usersDatabasePath)
    }
    
    private var firestoreReference: CollectionReference {
        fs.collection(FirebaseDatabasesPaths.reportsDatabasePath)
    }
        
    func setDelegate(_ delegate: FirebaseUserDelegate) {
        self.firebaseUserDelegate = delegate
    }
            
    /// Fetch the signed in users information.
    /// - Parameter uid: The Auth user uid.
    func fetchSignedInUserInformation(uid: String) async throws -> FirebaseUser {
        let userReference = reference.child(uid)
        
        guard try await userReference.getData().exists() else {
            throw FirebaseUserManagerError.doesNotExist
        }
        
        guard let data = try await userReference.getData().value else {
            throw FirebaseUserManagerError.dataError
        }
        
        guard let firebaseUser = JSONSerialization.objectFromData(FirebaseUser.self, jsonObject: data) else {
            throw FirebaseUserManagerError.codableError
        }
                
        return firebaseUser
    }
    
    /// Adds a report UUID to the user's bookmarks.
    /// - Parameters:
    ///   - reportId: The UUID of the report the user is bookmarking.
    func addBookmark(reportId: UUID) async throws {
        guard let userUid else {
            throw FirebaseUserManagerError.userIdError
        }
        
        guard try await ReportManager.manager.reportDoesExist(reportId) else {
            throw FirebaseUserManagerError.reportDoesNotExist
        }
        
        let userBookmarkReference = reference.child(userUid).child(FirebaseDatabasesPaths.userBookmarksPath)
        let currentBookmarks = try await getUserCurrentBookmarks()
        
        var bookmarks = currentBookmarks
        bookmarks.append(reportId)
        
        try await userBookmarkReference.setValue(bookmarks)
    }
    
    /// Removes a users bookmarked report.
    /// - Parameter reportId: The UUID of the report the user wants to no longer bookmark.
    func removeBookmark(reportId: UUID) async throws {
        guard let userUid else {
            throw FirebaseUserManagerError.userIdError
        }
        
        let userBookmarkReference = reference.child(userUid).child(FirebaseDatabasesPaths.userBookmarksPath)
        let currentBookmarks = try await getUserCurrentBookmarks()
        
        guard let bookmarkIndex = currentBookmarks.firstIndex(of: reportId) else { return }
        var bookmarks = currentBookmarks
        
        bookmarks.remove(at: bookmarkIndex)
        
        try await userBookmarkReference.setValue(bookmarks)
    }
    
    /// Retrives the signed in users current bookmarks.
    /// - Returns: The array of the user's bookmarked reports by UUIDs.
    private func getUserCurrentBookmarks() async throws -> [UUID] {
        guard let userUid else {
            throw FirebaseUserManagerError.userIdError
        }
        
        let userBookmarkReference = reference.child(userUid).child(FirebaseDatabasesPaths.userBookmarksPath)
        
        guard let currentBookmarks = try await userBookmarkReference.getData().value as? [UUID] else {
            throw FirebaseUserManagerError.bookmarksError
        }
        
        return currentBookmarks
    }
        
    /// Checks if a report is bookmarked.
    /// - Parameter reportId: The UUID of the report.
    /// - Returns: Bool deterimining if the users has this report bookmarked.
    func isBookmarked(_ reportId: UUID) async throws -> Bool {
        let userBookmarks = try await getUserCurrentBookmarks()
        guard userBookmarks.contains(where: {$0 == reportId}) else { return false }
        
        return true
    }
    
    func getUserReports() async throws -> [Report] {
        guard let userUid else { throw FirebaseUserManagerError.userIdError}
        
        let data = try await firestoreReference.whereField("uid", isEqualTo: userUid).getDocuments().documents.map({$0.data()})
        
        let userReports = data.map({JSONSerialization.objectFromData(Report.self, jsonObject: $0)})
        
        return userReports.compactMap({$0})
    }
    
    
    func getUserBookmarks() async throws -> [Report] {
        let reportIds = try await getUserCurrentBookmarks()
        
        var reports = [Report?]()
        
        for reportId in reportIds {
            let report = try await ReportManager.manager.fetchSingleReport(reportId)
            reports.append(report)
        }
        
        return reports.compactMap({$0})
    }
    
    deinit {
        firebaseUserDelegate = nil
        print("Dead: FirebaseUserManager")
    }
}
