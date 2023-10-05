//
//  LoginViewModel.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/25/23.
//

import Foundation
import FirebaseAuth
import Firebase
import SwiftUI

enum RootViewLoadStatus {
    case loading, loaded
}

@MainActor final class UserViewModel: ObservableObject {
    
    @Published private(set) var rootViewLoadStatus: RootViewLoadStatus = .loading
    
    private let firebaseManager = FirebaseUserManager()
    
    var uid: String? {
        Auth.auth().currentUser?.uid
    }
    
    //MARK: - Reports Methods
    
    func fetchUserReports() async throws -> [Report] {
        return try await firebaseManager.fetchUserReports()
    }
    
    func fetchUserBookmarks() async throws -> [Report] {
        return try await firebaseManager.fetchUserBookmarks()
    }
    
    func bookmarkReport(_ id: UUID) async throws {
        
    }
    
    func undoBookmark(_ id: UUID) async throws {
        
    }

    //MARK: - User Settings Methods
    
    func fetchNotificationSettings() async throws -> UserNotificationSettings {
        let settings = try await firebaseManager.fetchUserNotificationSettings()
        return settings
    }
    
    func saveNotificationSettings(_ settings: UserNotificationSettings) async throws {
        try await firebaseManager.saveUserNotificationSettings(settings)
    }
    
    //MARK: - Auth Methods
    
    func getAuthUserPhoneNumber() -> String? {
        return Auth.auth().currentUser?.phoneNumber
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            notifyOfSignOut()
        } catch {
            print("Unable to sign user out!")
        }
    }
    
    func deleteUserAccount() async throws {
        try await Auth.auth().currentUser?.delete()
    }
    
    private func notifyOfSignOut() {
        NotificationCenter.default.post(Notification.signOut)
    }
    
    deinit {
        print("Dead: UserViewModel")
    }
}

extension UserViewModel: FirebaseAuthDelegate {
    func userHasSignedIn(uid: String) async -> LoginStatus {
        withAnimation {
            self.rootViewLoadStatus = .loaded
        }
        
        return .signedIn
    }
}
