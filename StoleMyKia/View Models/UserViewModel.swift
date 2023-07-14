//
//  LoginViewModel.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/25/23.
//

import Foundation
import FirebaseAuth
import Firebase


final class UserViewModel: ObservableObject {
        
    @Published var showLoginProgressView = true
    
    @Published private(set) var isSignedIn = false
    
    @Published private(set) var firebaseUser: FirebaseUser?
    @Published private(set) var alertErrorLoggingIn = false
    
    private let accountManager = UserAccountManager()
            
    private let auth = Auth.auth()
        
    deinit {
        print("Dead: UserViewModel")
    }
}

//MARK: - FirebaseUserNotificationRadiusDelegate
extension UserViewModel: FirebaseUserNotificationRadiusDelegate {
    var usersRadius: Double? {
        guard let firebaseUser else {
            return nil
        }
        
        return firebaseUser.notificationSettings.notificationRadius
    }
    
    func setNewRadius(_ radius: Double, completion: @escaping (Bool) -> Void) {
        
    }
}

//MARK: - FirebaseUserDelegate
extension UserViewModel: FirebaseUserDelegate {
    var uid: String {
        return self.firebaseUser?.uid ?? "12345"
    }
}
