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

enum UserReportsLoadStatus {
    case loading, loaded([Report]), empty, error
}

@MainActor 
final class UserViewModel: NSObject, ObservableObject {
    
    //MARK: - User Report and Bookmarks Methods
    func getUserReports() async -> UserReportsLoadStatus {
        do {
            let reports = try await UserReportsManager.shared.fetchUserReports()
            guard !(reports.isEmpty) else {
                return .empty
            }
            return .loaded(reports)
        } catch {
            return .error
        }
    }
    
    func getUserBookmarks() async -> UserReportsLoadStatus {
        do {
            let reports = try await UserReportsManager.shared.fetchUserBookmarks()
            guard !(reports.isEmpty) else {
                return .empty
            }
            return .loaded(reports)
        } catch {
            return .error
        }
    }
        
    //MARK: - User Settings Methods
    
    func fetchNotificationSettings() async throws -> UserNotificationSettings? {
        let settings = try await FirebaseUserManager.shared.fetchUserNotificationSettings()
        return settings
    }
    
    func saveNotificationSettings(_ settings: UserNotificationSettings) async throws {
        try await FirebaseUserManager.shared.saveUserNotificationSettings(settings)
    }
    
    //MARK: - Auth Methods
    
    func getAuthUserPhoneNumber() -> String? {
        return Auth.auth().currentUser?.phoneNumber
    }
    
    func getUserAccountStatus() async -> String {
        return await FirebaseUserManager.shared.getUserAccountStatus()
    }
    
    func signOut() {
        FirebaseAuthManager.manager.signOutUser()
    }
    
    func deleteUserAccount() async throws {
        try await FirebaseAuthManager.manager.permanentlyDeleteUser()
    }
    
    deinit {
        print("Dead: UserViewModel")
    }
}
