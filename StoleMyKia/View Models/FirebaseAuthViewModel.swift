//
//  FirebaseAuthViewModel.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 7/16/23.
//

import Foundation
import Firebase

enum LoginStatus {
    case signedOut, loading, onboarding, signedIn
}

@MainActor 
final class FirebaseAuthViewModel: NSObject, ObservableObject {
    
    @Published private var isSigningOut = false
    
    @Published private(set) var loginStatus: LoginStatus = .loading
        
    private let authManager = FirebaseAuthManager.manager
    
    private var uid: String?
    
    override init() {
        super.init()
        //FIXME: One of these methods are causes preview's to crash when injecting the environment object
        self.checkForDeviceID()
        self.checkForCurrentUser()
        self.beginListeningForSignOut()
    }
    
    func authWithPhoneNumber(_ phoneNumber: String) async throws {
        try await self.authManager.authWithPhoneNumber(phoneNumber)
    }
    
    func verifyCode(_ code: String, phoneNumber: String) async throws {
        let loginStatus = try await authManager.verifyCode(code, phoneNumber: phoneNumber)
        
        guard let user = Auth.auth().currentUser else {
            throw FirebaseAuthManager.FirebaseAuthManagerError.userError
        }
                
        self.prepareForSignIn(uid: user.uid, loginStatus: loginStatus)
    }
    
    /// Begin setting up the application after successful sign in.
    /// - Parameter uid: The Firebase auth user uid.
    private func prepareForSignIn(uid: String, loginStatus: LoginStatus = .signedIn) {
        self.uid = uid
        self.loginStatus = loginStatus
        self.beginListeningForFCMToken()
        self.setupAccountDeletionListener()
    }
    
    @objc 
    private func userHasSignedOut() {
        self.isSigningOut = true
        self.prepareForSignOut(fatal: true)
    }
    
    @objc 
    private func saveDeviceFCMToken(_ notification: NSNotification) {
        if let userInfo = notification.userInfo, let deviceID = UserDefaults.standard.string(forKey: Constants.deviceIDKey) {
            let deviceToken = userInfo[Constants.deviceToken] as! String
            var info = [String: Any]()
            info[Constants.deviceIDKey] = deviceID
            info[Constants.deviceToken] = deviceToken
            
            FirebaseUserManager.saveFCMToken(info: info)
        }
    }
    
    private func removeDeviceFCMToken() async throws {
        try await FirebaseUserManager.deleteFCMToken(uid)
    }
    
    ///Begin setting up the application for sign out.
    private func prepareForSignOut(fatal: Bool = false) {
        Task {
            do {
                try Auth.auth().signOut()
                FirebaseAuthManager.manager.removeListener()
                
                suspendListeningForFCMToken()
                self.loginStatus = .loading
                try? await removeDeviceFCMToken()
                NotificationManager.removeNotificationListener()
                
                //Removing notifications and resetting application badge...
                UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                
                if #available(iOS 17.0, *) {
                    try? await UNUserNotificationCenter.current().setBadgeCount(0)
                } else {
                    UIApplication.shared.applicationIconBadgeNumber = 0
                }
                
                self.loginStatus = .signedOut
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.isSigningOut = false
                }
            } catch {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.isSigningOut = false
                }
            }
        }
    }
    
    private func checkForDeviceID() {
        if (UserDefaults.standard.string(forKey: Constants.deviceIDKey) == nil) {
            UserDefaults.standard.setValue(UUID().uuidString, forKey: Constants.deviceIDKey)
        }
    }
    
    private func checkForCurrentUser() {
        Task {
            self.loginStatus = .loading
            do {
                let (user, uid) = try await authManager.fetchCurrentUserDocument()
                
                var loginStatus: LoginStatus
                
                switch user.status {
                case .newUser:
                    loginStatus = .onboarding
                case .active:
                    loginStatus = .signedIn
                case .disabled:
                    loginStatus = .signedIn
                case .banned:
                    loginStatus = .signedOut
                }
                
                self.prepareForSignIn(uid: uid, loginStatus: loginStatus)
            } catch {
                prepareForSignOut(fatal: false)
            }
        }
    }
    
    private func setupAccountDeletionListener() {
        authManager.beginListeningForAccountDeletion {
            if !(self.isSigningOut) {
                notifyUserOfSignOut()
            }
        }
        
        func notifyUserOfSignOut() {
            let ac = UIAlertController(title: "You have been signed out.", message: "Please sign in to continue using the application!", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.prepareForSignOut(fatal: true)
            }
            ac.addAction(action)
            UIApplication.shared.topViewController()?.present(ac, animated: true)
        }
    }
    
    func completeOnboarding() async throws {
        try await authManager.setCurrentUserToActive()
        self.loginStatus = .signedIn
    }
    
    
    private func beginListeningForFCMToken() {
        NotificationCenter.default.addObserver(self, selector: #selector(saveDeviceFCMToken(_:)), name: .deviceFCMToken, object: nil)
    }
    
    private func suspendListeningForFCMToken() {
        NotificationCenter.default.removeObserver(self, name: .deviceFCMToken, object: nil)
    }
    
    private func beginListeningForSignOut() {
        NotificationCenter.default.addObserver(self, selector: #selector(userHasSignedOut), name: .signOut, object: nil)
    }
    
    ///Deletes signed in users information (reports, device tokens, notifications, etc.)
    func permanentlyDeleteUser() async throws {
        guard let currentUser = Auth.auth().currentUser else {
            throw FirebaseAuthManager.FirebaseAuthManagerError.error
        }
        
        try await FirebaseAuthManager.manager.userCanPerformDestructiveAction()
        
        let reportsCollection = Firestore.firestore()
            .collection(FirebaseDatabasesPaths.reportsDatabasePath)
        
        self.isSigningOut = true
            
        //Delete reports...
        try await reportsCollection
            .whereFilter(.whereField("uid", isEqualTo: currentUser.uid))
            .getDocuments()
            .documents
            .forEach { doc in
                reportsCollection
                    .document(doc.documentID)
                    .delete()
            }
        
        let userDocumentRef = try await Firestore.firestore()
            .collection(FirebaseDatabasesPaths.usersDatabasePath)
            .document(currentUser.uid)
            .getDocument()
            .reference
        
        //Delete bookmarks
        try await userDocumentRef
            .collection(FirebaseDatabasesPaths.userBookmarksPath)
            .getDocuments()
            .documents
            .forEach { doc in
                userDocumentRef
                    .collection(FirebaseDatabasesPaths.userBookmarksPath)
                    .document(doc.documentID)
                    .delete()
            }
        
        //Delete Notifications
        try await userDocumentRef
            .collection(FirebaseDatabasesPaths.userNotificationPath)
            .getDocuments()
            .documents
            .forEach { doc in
                userDocumentRef
                    .collection(FirebaseDatabasesPaths.userNotificationPath)
                    .document(doc.documentID)
                    .delete()
            }
        
        //Delete device tokens
        try await userDocumentRef
            .collection(FirebaseDatabasesPaths.fcmTokenPath)
            .getDocuments()
            .documents
            .forEach { doc in
                userDocumentRef
                    .collection(FirebaseDatabasesPaths.fcmTokenPath)
                    .document(doc.documentID)
                    .delete()
            }
        
        //Delete settings
        try await userDocumentRef
            .collection(FirebaseDatabasesPaths.userSettingsPath)
            .getDocuments()
            .documents
            .forEach { doc in
                userDocumentRef
                    .collection(FirebaseDatabasesPaths.userSettingsPath)
                    .document(doc.documentID)
                    .delete()
            }
        
        try await userDocumentRef.delete()
        
        try? await Auth.auth().currentUser?.delete()
        FirebaseAuthManager.manager.removeListener()
        userHasSignedOut()
    }
    
    func signOutUser() {
        try? Auth.auth().signOut()
        userHasSignedOut()
    }
    
    deinit {
        Task {
            await suspendListeningForFCMToken()
        }
    }
}
