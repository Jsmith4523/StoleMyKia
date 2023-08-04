//
//  FirebaseAuthViewModel.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 7/16/23.
//

import Foundation
import FirebaseAuth
import FirebaseMessaging

enum LoginStatus {
    case signedOut, signedIn
}

@MainActor
class FirebaseAuthViewModel: ObservableObject {
    
    @Published private(set) var loginStatus: LoginStatus = .signedOut
    
    private let authManager = FirebaseAuthManager.manager
    weak private var firebaseAuthDelegate: FirebaseAuthDelegate?
    
    init() {
        createAuthStateListener()
    }
    
    func setDelegate(_ delegate: FirebaseAuthDelegate) {
        self.firebaseAuthDelegate = delegate
    }
    
    
    func authWithPhoneNumber(_ phoneNumber: String) async throws {
        try await authManager.authWithPhoneNumber(phoneNumber)
    }
    
    /// Begin setting up the application after successful sign in.
    /// - Parameter uid: The Firebase auth user uid.
    private func prepareForSignIn(uid: String) {
        self.loginStatus = .signedIn
        Task {
            guard let status = await firebaseAuthDelegate?.userHasSignedIn(uid: uid) else {
                self.loginStatus = .signedOut
                return
            }
            self.loginStatus = status
        }
    }
    
    ///Begin setting up the application for sign out.
    private func prepareForSignOut() {
        try? authManager.signOutUser()
        
        self.firebaseAuthDelegate?.userHasSignedOut()
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
    
    private func createAuthStateListener() {
        Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let user else {
                self?.prepareForSignOut()
                return
            }
            self?.prepareForSignIn(uid: user.uid)
        }
    }
}

protocol FirebaseAuthDelegate: AnyObject {
    ///Called when the Firebase Auth user has succesfully signed in.
    func userHasSignedIn(uid: String) async -> LoginStatus
    ///Callled when the Firebase Auth user is signing out.
    func userHasSignedOut()
}
