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
            self.verificationId = nil
            
            return try await saveNewUser(phoneNumber: phoneNumber, userDocument: userDocument)
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
            
            guard !(AppUser.Status(rawValue: rawValue) == nil) else {
                throw FirebaseAuthManagerError.userStatusError("Invalid user status!")
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
        
        let deletionListener = userDocument.addSnapshotListener { snapshot, err in
            guard let snapshot, err == nil else { return }
            
            guard let rawValue = snapshot.get(AppUser.statusKey) as? String else {
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
    
    ///Deletes signed in users information (reports, device tokens, notifications, etc.)
    func permanentlyDeleteUser() async throws {
        guard let currentUser = Auth.auth().currentUser else {
            throw FirebaseAuthManagerError.error
        }
        
        try await userCanPerformDestructiveAction()
        
        let reportsCollection = Firestore.firestore()
            .collection(FirebaseDatabasesPaths.reportsDatabasePath)
            
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
        notifyOfSignOut()
    }
    
    func signOutUser() {
        try? Auth.auth().signOut()
        notifyOfSignOut()
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
