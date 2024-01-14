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
        case userSignedOut
        case userDoesNotExist
        case userAlreadyExist
        case userBanned
        case userDisabled
        case userStatusError(String)
        case error
        case specificError(String)
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
    
    func verifyCode(_ code: String, phoneNumber: String) async throws -> LoginStatus {
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
            
            if let userDocument, userDocument.exists {
                let userData = try JSONSerialization.data(withJSONObject: userDocument.data())
                let user = try JSONDecoder().decode(AppUser.self, from: userData)
                
                guard let currentUser = Auth.auth().currentUser else {
                    throw FirebaseAuthManagerError.userSignedOut
                }
                
                //If the user id is mismatch of the user, but the phone number provided is the user's phone number
                //Update the user id field
                guard currentUser.uid == user.uid && phoneNumber == user.phoneNumber else {
                    throw FirebaseAuthManagerError.specificError("The user document id and phone number do not match with the signed in user")
                }
                
                if user.status == .newUser {
                    self.verificationId = nil
                    return .onboarding
                }
            }
            
            self.verificationId = nil
            return try await saveNewUser(phoneNumber: phoneNumber, userDocument: userDocument)
            
        } catch let error as FirebaseAuthManagerError {
            throw error
        } catch {
            try? Auth.auth().signOut()
            throw FirebaseAuthManagerError.error
        }
        
        func checkUserStatus(userDoc: DocumentSnapshot) async throws {
            guard let rawValue = userDoc.get(AppUser.statusKey) as? String else {
                throw FirebaseAuthManagerError.userStatusError("Status field is missing!")
            }
            
            guard let status = AppUser.Status(rawValue: rawValue) else {
                throw FirebaseAuthManagerError.userStatusError("Invalid user status!")
            }
            
            guard !(status == .banned) else {
                throw FirebaseAuthManagerError.userBanned
            }
        }
        
        func saveNewUser(phoneNumber: String, userDocument: DocumentSnapshot?) async throws -> LoginStatus {
            guard let currentUser = Auth.auth().currentUser else {
                throw FirebaseAuthManagerError.userError
            }
            
            let userData = try AppUser(uid: currentUser.uid, status: .newUser, phoneNumber: phoneNumber)
                .encodeForUpload()
            
            guard (userDocument == nil) else {
                return .signedIn
            }
            
            try await Firestore.firestore()
                .collection(FirebaseDatabasesPaths.usersDatabasePath)
                .document(currentUser.uid)
                .setData(userData)
            
            return .onboarding
        }
    }
    
    func beginListeningForAccountDeletion(deleteCompletion: @escaping () -> ()) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let userDocument = Firestore.firestore()
            .collection(FirebaseDatabasesPaths.usersDatabasePath)
            .document(currentUser.uid)
        
        let deletionListener = userDocument.addSnapshotListener(includeMetadataChanges: true) { snapshot, err in
            guard let snapshot, err == nil else { return }
            
            guard snapshot.exists else {
                deleteCompletion()
                return
            }
            
            guard let rawValue = snapshot.get(AppUser.statusKey) as? String else {
                deleteCompletion()
                return
            }
                        
            let userStatus = AppUser.Status(rawValue: rawValue)
            
            guard let userStatus, (userStatus == .active || userStatus == .disabled || userStatus == .newUser) else {
                deleteCompletion()
                return
            }
        }
        
        self.accountDeletionListener = deletionListener
    }
    
    func removeListener() {
        self.accountDeletionListener?.remove()
        self.accountDeletionListener = nil
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
        
        guard userSnapshot.exists else {
            throw FirebaseAuthManagerError.userDoesNotExist
        }
        
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
    func userCanPerformDestructiveAction() async throws {
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
            throw FirebaseAuthManagerError.userSignedOut
        }
        
        let (user, _) = try await fetchCurrentUserDocument()
        
        guard (user.status == .active) else {
            throw FirebaseAuthManagerError.userStatusError("User account is either disabled, banned, has been deleted, or has another label.")
        }
    }
    
    func fetchCurrentUserDocument() async throws -> (AppUser, String) {
        guard let currentUser = Auth.auth().currentUser else {
            throw FirebaseAuthManagerError.userSignedOut
        }
        
        let userSnapshot = try await Firestore.firestore()
            .collection(FirebaseDatabasesPaths.usersDatabasePath)
            .document(currentUser.uid)
            .getDocument()
        
        guard let userData = userSnapshot.data() else {
            throw FirebaseAuthManagerError.error
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: userData)
            let user = try JSONDecoder().decode(AppUser.self, from: data)
            return (user, currentUser.uid)
        } catch {
            throw FirebaseAuthManagerError.specificError("User Decoding Error")
        }
    }
    
    ///Sets the current signed in user docu
    func setCurrentUserToActive() async throws {
        guard let currentUser = Auth.auth().currentUser else {
            throw FirebaseAuthManagerError.userSignedOut
        }
        
        let userDocument = try await Firestore.firestore()
            .collection(FirebaseDatabasesPaths.usersDatabasePath)
            .document(currentUser.uid)
            .getDocument()
        
        guard userDocument.exists else {
            throw FirebaseAuthManagerError.userDoesNotExist
        }
        
        try await Firestore.firestore()
            .collection(FirebaseDatabasesPaths.usersDatabasePath)
            .document(currentUser.uid)
            .updateData([AppUser.CodingKeys.status.rawValue: AppUser.Status.active.rawValue])
    }
    
    func userCanHandleNotification() async throws -> Bool {
        guard let currentUser = Auth.auth().currentUser else {
            return false
        }
        
        let status = try await Firestore
            .firestore()
            .collection(FirebaseDatabasesPaths.usersDatabasePath)
            .document(currentUser.uid)
            .getDocument()
            .exists
        
        return status
    }
        
    private func notifyOfSignOut() {
        NotificationCenter.default.post(Notification.signOut)
    }
}
