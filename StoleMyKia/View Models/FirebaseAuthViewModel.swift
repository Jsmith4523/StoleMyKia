//
//  FirebaseAuthViewModel.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 7/16/23.
//

import Foundation
import Firebase

enum LoginStatus {
    case signedOut, loading, signedIn
}

@MainActor class FirebaseAuthViewModel: NSObject, ObservableObject {
    
    @Published private(set) var loginStatus: LoginStatus = .signedOut
        
    private let authManager = FirebaseAuthManager.manager
    
    private var uid: String?
    
    override init() {
        super.init()
        checkForDeviceID()
        checkForCurrentUser()
        beginListeningForSignOut()
    }
    
    func authWithPhoneNumber(_ phoneNumber: String) async throws {
        try await self.authManager.authWithPhoneNumber(phoneNumber)
    }
    
    func verifyCode(_ code: String, phoneNumber: String) async throws {
        try await authManager.verifyCode(code, phoneNumber: phoneNumber)
        
        guard let user = Auth.auth().currentUser else {
            throw FirebaseAuthManager.FirebaseAuthManagerError.userError
        }
        
        prepareForSignIn(uid: user.uid)
    }
    
    /// Begin setting up the application after successful sign in.
    /// - Parameter uid: The Firebase auth user uid.
    private func prepareForSignIn(uid: String) {
        self.uid = uid
        self.loginStatus = .signedIn
        self.beginListeningForFCMToken()
        self.setupAccountDeletionListener()
    }
    
    @objc 
    private func userHasSignedOut() {
        self.prepareForSignOut(fatal: true)
    }
    
    @objc private func saveDeviceFCMToken(_ notification: NSNotification) {
        if let userInfo = notification.userInfo, let deviceID = UserDefaults.standard.string(forKey: Constants.deviceIDKey) {
            let deviceToken = userInfo[Constants.deviceToken] as! String
            var info = [String: Any]()
            info[Constants.deviceIDKey] = deviceID
            info[Constants.deviceToken] = deviceToken
            
            FirebaseUserManager.saveFCMTOken(info: info)
        }
    }
    
    private func removeDeviceFCMToken() async throws {
        try await FirebaseUserManager.deleteFCMToken(uid)
    }
    
    ///Begin setting up the application for sign out.
    private func prepareForSignOut(shouldImmediatelySignOut: Bool = false, fatal: Bool = false) {
        Task {
            do {
                if shouldImmediatelySignOut {
                    authManager.signOutUser()
                }
                
                suspendListeningForFCMToken()
                if fatal {
                    self.loginStatus = .loading
                }
                try await removeDeviceFCMToken()
                NotificationManager.removeNotificationListener()
                
                //Removing notifications and resetting application badge...
                UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                
                if #available(iOS 17.0, *) {
                    try await UNUserNotificationCenter.current().setBadgeCount(0)
                } else {
                    UIApplication.shared.applicationIconBadgeNumber = 0
                }
                if fatal {
                    fatalError()
                }
            } catch {
                fatalError()
            }
        }
    }
    
    private func checkForDeviceID() {
        if (UserDefaults.standard.string(forKey: Constants.deviceIDKey) == nil) {
            UserDefaults.standard.setValue(UUID().uuidString, forKey: Constants.deviceIDKey)
        }
    }
    
    private func checkForCurrentUser() {
        guard let user = Auth.auth().currentUser else {
            self.loginStatus = .signedOut
            prepareForSignOut(fatal: false)
            return
        }
        
        self.prepareForSignIn(uid: user.uid)
    }
    
    private func setupAccountDeletionListener() {
        authManager.beginListeningForAccountDeletion {
            notifyUserOfSignOut()
        }
        
        func notifyUserOfSignOut() {
            let ac = UIAlertController(title: "You have been signed out.", message: "Please sign in to continue using the application!", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.prepareForSignOut(fatal: true)
            }
            ac.addAction(action)
            
            UIApplication.shared.windows.first?.rootViewController?.show(ac, sender: nil)
        }
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
    
    deinit {
        Task {
            await suspendListeningForFCMToken()
        }
    }
}
