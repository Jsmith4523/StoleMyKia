//
//  FirebaseAuthViewModel.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 7/16/23.
//

import Foundation
import FirebaseAuth

enum LoginLoadStatus {
    case signedOut, signedIn
}

///Handles Firebase Authenfication events and actions such as sign in/out, account creation, and authenification states
class FirebaseAuthViewModel: ObservableObject {
    
    @Published private(set) var loginStatus: LoginLoadStatus = .signedIn
    
    private let auth = Auth.auth()
    
    weak private var firebaseAuthDelegate: FirebaseAuthDelegate?
    
    init() {
        guard let user = Auth.auth().currentUser else {
            self.prepareForSignOut()
            return
        }
        self.prepareForSignIn(uid: user.uid)
    }
    
    func setDelegate(_ delegate: FirebaseAuthDelegate) {
        self.firebaseAuthDelegate = delegate
    }
    
    /// Begin setting up the application for sign in.
    /// - Parameter uid: The Firebase auth user uid.
    private func prepareForSignIn(uid: String) {
        self.loginStatus = .signedIn
        
        Task {
            guard let status = await firebaseAuthDelegate?.userHasSignedIn(uid: uid) else {
                prepareForSignOut()
                return
            }
            self.loginStatus = status
        }
    }
    
    ///Begin setting up the application for sign out.
    private func prepareForSignOut() {
        try? auth.signOut()
        
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
}

protocol FirebaseAuthDelegate: AnyObject {
    ///Called when the Firebase Auth user has succesfully signed in.
    func userHasSignedIn(uid: String) async -> LoginLoadStatus
    ///Callled when the Firebase Auth user is signing out.
    func userHasSignedOut()
}
