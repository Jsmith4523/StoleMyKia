//
//  FirebaseAuthManager.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 8/4/23.
//

import Foundation
import Firebase

class FirebaseAuthManager {
    
    enum FirebaseAuthManagerError: Error {
        case verificationIdError
        case userError
        case userDoesNotExist
        case userAlreadyExist
        case userBanned
        case userDisabled
        case userStatusError(String)
        case error
    }
        
    private var verificationId: String?
    
    private var accountDeletionListener: ListenerRegistration?
    
    ///Shared instance
    static let manager = FirebaseAuthManager()
    
    private init() {}
    
    /// Authenticate with users phone number
    /// - Parameter phoneNumber: The users phone number
    func authWithPhoneNumber(_ phoneNumber: String) async throws {
        let verificationId = try await PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil)
        self.verificationId = verificationId
    }
    
    func verifyCode(_ code: String, phoneNumber: String) async throws {
        guard let verificationId else {
            throw FirebaseAuthManagerError.verificationIdError
        }
        
        do {
            let userDocument = try await Firestore.firestore()
                .collection(FirebaseDatabasesPaths.usersDatabasePath)
                .whereField(AppUser.CodingKeys.phoneNumber.rawValue, isEqualTo: phoneNumber)
                .getDocuments()
                .documents
                .first
            
            if let userDocument, userDocument.exists {
                try await checkUserStatus(userDoc: userDocument)
            }
            
            let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId, verificationCode: code)
            try await Auth.auth().signIn(with: credential)
            try await saveNewUser(phoneNumber: phoneNumber, userDocument: userDocument)
            
            self.verificationId = nil
        } catch {
            print(error)
            self.verificationId = nil
            try? Auth.auth().signOut()
            throw FirebaseAuthManagerError.error
        }
        
        func checkUserStatus(userDoc: DocumentSnapshot) async throws {
            guard let rawValue = userDoc.get(AppUser.statusKey) as? String else {
                throw FirebaseAuthManagerError.userStatusError("Status field is missing!")
            }
            
            guard let userStatus = AppUser.Status(rawValue: rawValue) else {
                throw FirebaseAuthManagerError.userStatusError("Invalid user status!")
            }
            
            guard !(userStatus == .banned) else {
                throw FirebaseAuthManagerError.userBanned
            }
            
            guard !(userStatus == .disabled) else {
                throw FirebaseAuthManagerError.userDisabled
            }
        }
        
        func saveNewUser(phoneNumber: String, userDocument: DocumentSnapshot?) async throws {
            let userData = try AppUser(status: .active, phoneNumber: phoneNumber)
                .encodeForUpload()
            
            guard let currentUser = Auth.auth().currentUser else {
                throw FirebaseAuthManagerError.userError
            }
            
            guard (userDocument == nil) else { return }
            
            try await Firestore.firestore()
                .collection(FirebaseDatabasesPaths.usersDatabasePath)
                .document(currentUser.uid)
                .setData(userData)
        }
    }
    
    func beginListeningForAccountDeletion(deleteCompletion: @escaping () -> ()) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let userDocument = Firestore.firestore()
            .collection(FirebaseDatabasesPaths.usersDatabasePath)
            .document(currentUser.uid)
        
        let deletionListener = userDocument.addSnapshotListener { snapshot, err in
            guard let snapshot, err == nil else { return }
            
            guard let rawValue = snapshot.get(AppUser.statusKey) as? String  else {
                deleteCompletion()
                return
            }
            
            let userStatus = AppUser.Status(rawValue: rawValue)
            
            guard let userStatus, (userStatus == .active || userStatus == .disabled) else {
                deleteCompletion()
                return
            }
        }
        
        self.accountDeletionListener = deletionListener
    }
    
    ///Determines if another user can have actions performed to their account such as having a report updated by another user
    func userCanPerformAction(uid: String) async throws {
        guard Auth.auth().currentUser.isSignedIn else {
            throw FirebaseAuthManagerError.error
        }
        
        let userSnapshot = try await Firestore.firestore()
            .collection(FirebaseDatabasesPaths.usersDatabasePath)
            .document(uid)
            .getDocument()
        
        //If the parameter uid passed through does not have a document at the collection, or the status is not "Active"
        //Then we cannot perform an action for that user
        guard let rawValue = userSnapshot.get(AppUser.statusKey) as? String  else {
            throw FirebaseAuthManagerError.userStatusError("Status Field is missing!")
        }
        
        guard let userStatus = AppUser.Status(rawValue: rawValue), (userStatus == .active) else {
            throw FirebaseAuthManagerError.userBanned
        }
    }
    
    
    ///The logged in user can perform destructive actions such as deleting their account or deleting a report
    private func userCanPerformDestructiveAction() async throws {
        guard let currentUser = Auth.auth().currentUser else {
            throw FirebaseAuthManagerError.error
        }
        
        let userSnapshot = try await Firestore.firestore()
            .collection(FirebaseDatabasesPaths.usersDatabasePath)
            .document(currentUser.uid)
            .getDocument()
        
        guard let rawValue = userSnapshot.get(AppUser.statusKey) as? String  else {
            throw FirebaseAuthManagerError.userStatusError("Status Field is missing!")
        }
        
        guard let userStatus = AppUser.Status(rawValue: rawValue), (userStatus == .active || userStatus == .disabled) else {
            throw FirebaseAuthManagerError.userBanned
        }
    }
    
    ///The logged in user can perform actions such as uploading or updating a report
    func userCanPerformAction() async throws {
        guard let currentUser = Auth.auth().currentUser else {
            throw FirebaseAuthManagerError.error
        }
        
        let userSnapshot = try await Firestore.firestore()
            .collection(FirebaseDatabasesPaths.usersDatabasePath)
            .document(currentUser.uid)
            .getDocument()
        
        guard let rawValue = userSnapshot.get(AppUser.statusKey) as? String  else {
            throw FirebaseAuthManagerError.userStatusError("Status Field is missing!")
        }
        
        guard let userStatus = AppUser.Status(rawValue: rawValue), (userStatus == .active) else {
            throw FirebaseAuthManagerError.userStatusError("User account is either disabled, banned, or has another label.")
        }
    }
    
    ///Deletes a users existence!!!
    func permanentlyDeleteUser() async throws {
        guard let currentUser = Auth.auth().currentUser else {
            throw FirebaseAuthManagerError.error
        }
        
        try await userCanPerformDestructiveAction()
        
        try await Firestore.firestore()
            .collection(FirebaseDatabasesPaths.usersDatabasePath)
            .document(currentUser.uid)
            .delete()
        
        try? await Auth.auth().currentUser?.delete()
        notifyOfSignOut()
    }
    
    func signOutUser() {
        try? Auth.auth().signOut()
        notifyOfSignOut()
    }
        
    private func notifyOfSignOut() {
        NotificationCenter.default.post(Notification.signOut)
    }
}
