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

@MainActor final class UserViewModel: NSObject, ObservableObject {
        
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
    
    func signOut() {
        do {
            try FirebaseAuthManager.manager.signOutUser()
        } catch {
            print("Unable to sign user out!")
        }
    }
    
    func deleteUserAccount() async throws {
        try await FirebaseAuthManager.manager.permanentlyDeleteUser()
    }
    
    deinit {
        print("Dead: UserViewModel")
    }
}
