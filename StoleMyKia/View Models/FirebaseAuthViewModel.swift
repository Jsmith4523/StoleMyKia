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
        self.uid = uid
        self.loginStatus = .signedIn
        self.beginListeningForFCMToken()
    }
    
    @objc private func userHasSignedOut() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.loginStatus = .signedOut
                self.prepareForSignOut()
            }
        }
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
    
    private func removeDeviceFCMToken() {
        FirebaseUserManager.deleteFCMToken(uid)
    }
    
    ///Begin setting up the application for sign out.
    private func prepareForSignOut(shouldImmediatelySignOut: Bool = false) {
        do {
            if !(shouldImmediatelySignOut) {
                try authManager.signOutUser()
            }
            
            suspendListeningForFCMToken()
            removeDeviceFCMToken()
            NotificationManager.removeNotificationListener()
            
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
        } catch {}
    }
    
    private func checkForDeviceID() {
        if (UserDefaults.standard.string(forKey: Constants.deviceIDKey) == nil) {
            UserDefaults.standard.setValue(UUID().uuidString, forKey: Constants.deviceIDKey)
        }
    }
    
    private func checkForCurrentUser() {
        guard let user = Auth.auth().currentUser else {
            self.loginStatus = .signedOut
            prepareForSignOut()
            return
        }
        self.prepareForSignIn(uid: user.uid)
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
    
    deinit {
        Task {
            await suspendListeningForFCMToken()
        }
    }
}
