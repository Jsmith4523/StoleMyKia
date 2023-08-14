//
//  FirebaseAuthViewModel.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 7/16/23.
//

import Foundation
import Firebase

enum LoginStatus {
    case signedOut, signedIn
}

@MainActor
class FirebaseAuthViewModel: ObservableObject {
    
    @Published private(set) var loginStatus: LoginStatus = .signedOut
    
    private let authManager = FirebaseAuthManager.manager
    weak var firebaseAuthDelegate: FirebaseAuthDelegate?
    
    init() {
        guard let user = Auth.auth().currentUser else {
            self.loginStatus = .signedOut
            prepareForSignOut()
            return
        }
        self.prepareForSignIn(uid: user.uid)
        self.loginStatus = .signedIn
    }
    
    func setDelegate(_ delegate: FirebaseAuthDelegate) {
        self.firebaseAuthDelegate = delegate
    }
    
    func authWithPhoneNumber(_ phoneNumber: String) async throws {
        try await authManager.authWithPhoneNumber(phoneNumber)
    }
    
    func verifyCode(_ code: String) async throws {
        try await authManager.verifyCode(code)
        
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        prepareForSignIn(uid: user.uid)
    }
    
    /// Begin setting up the application after successful sign in.
    /// - Parameter uid: The Firebase auth user uid.
    private func prepareForSignIn(uid: String) {
        self.loginStatus = .signedIn
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            Task {
                guard let status = await self.firebaseAuthDelegate?.userHasSignedIn(uid: uid) else {
                    self.loginStatus = .signedOut
                    return
                }
                self.loginStatus = status
            }
        }
    }
    
    ///Begin setting up the application for sign out.
    private func prepareForSignOut() {
        try? authManager.signOutUser()
        
        //self.firebaseAuthDelegate?.userHasSignedOut()
        self.loginStatus = .signedOut
        
        //Removing notifications and resetting application badge...
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        if #available(iOS 17.0, *) {
            UNUserNotificationCenter.current().setBadgeCount(0)
        } else {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
}

//MARK: - UserViewModelDelegate
extension FirebaseAuthViewModel: UserViewModelDelegate {
    func userDidSuccessfullySignOut() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.loginStatus = .signedOut
                self.prepareForSignOut()
            }
        }
    }
}

protocol FirebaseAuthDelegate: AnyObject {
    ///Called when the Firebase Auth user has succesfully signed in.
    func userHasSignedIn(uid: String) async -> LoginStatus
    ///Callled when the Firebase Auth user is signing out.
    func userHasSignedOut()
}
