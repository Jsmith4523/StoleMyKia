//
//  LoginViewModel.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/25/23.
//

import Foundation
import FirebaseAuth
import Firebase

@MainActor
final class UserViewModel: ObservableObject {
        
    @Published var showLoginProgressView = true
    @Published private(set) var userIsSignedIn = false
    
    @Published private(set) var currentUser: User!
    @Published private(set) var firebaseUser: FirebaseUser! {
        didSet {
            print(firebaseUser)
        }
    }
    
    private let accountManager = UserAccountManager()
            
    private let auth = Auth.auth()
    
    weak var userReportsDelegate: UserReportsDelegate?
    
    init() {
        setupUserListener()
    }
    
    func getUserCreationDate() -> Date? {
        guard let date = currentUser.metadata.creationDate else {
            return nil
        }
        
        return date
    }
    
    func containsBookmarkReport(id: UUID) -> Bool {
        guard let firebaseUser, firebaseUser.hasBookmark(id) else {
            return false
        }
        
        return true
    }
    
    func bookmarkReport(id: UUID, completion: @escaping (Bool) -> Void) {
        guard let firebaseUser else {
            completion(false)
            return
        }
        
        var user = firebaseUser
        user.addReportToBookmark(id)
        
        saveChanges(user: user) { status in
            completion(status)
        }
    }
    
    func removeBookmark(id: UUID, completion: @escaping (Bool) -> Void) {
        guard let firebaseUser else {
            completion(false)
            return
        }
        
        var user = firebaseUser
        user.removeReportFromBookmark(id)
        
        saveChanges(user: user) { status in
            completion(status)
        }
    }
    
    private func saveChanges(user: FirebaseUser, completion: @escaping (Bool) -> Void) {
        var oldFirebaseUser = self.firebaseUser
        
        accountManager.saveAccountChanges(user: user) { status in
            //Setting the previous value of the user if false...
            guard status else {
                self.firebaseUser = oldFirebaseUser
                return
            }
            
            self.getUserData()
            completion(status)
        }
    }
    
    private func getUserData() {
        guard let currentUser else {
            return
        }
        
        accountManager.getUserData(currentUser.uid) { result in
            switch result {
            case .success(let user):
                self.firebaseUser = user
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func getUserDisplayName() -> String {
        guard let user = currentUser, let name = user.displayName else {
            return "N/A"
        }
        
        return name
    }
    
    func signIn(email: String, password: String, completion: @escaping ((Bool?)->Void)) {
        auth.signIn(withEmail: email, password: password) { result, err in
            guard result != nil, err == nil else {
                completion(false)
                return
            }
        }
    }
    
    func sendResetPasswordLink(to email: String, completion: @escaping ((Bool?)->Void)) {
        auth.sendPasswordReset(withEmail: email) { err in
            guard err == nil else {
                completion(false)
                return
            }
        }
    }
    
    func verifyResetPasscode(code: String, completion: @escaping ((Bool?)->Void)) {
        auth.verifyPasswordResetCode(code) { _, err in
            guard err == nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    func signUp(email: String, password: String, completion: @escaping ((Bool?)->Void)) {
        auth.createUser(withEmail: email, password: password) { result, err in
            guard result != nil, err == nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    ///WARNING: Deletes the signed in users account entirely!
    func deleteAccount(completion: @escaping ((Bool?)->Void)) {
        guard let firebaseUser else {
            completion(false)
            return
        }
        
        userReportsDelegate?.deleteAll { success in
            guard success else {
                completion(false)
                return
            }
            self.auth.currentUser?.delete { err in
                guard err == nil else {
                    print(err?.localizedDescription ?? "There was an error")
                    completion(false)
                    return
                }
                self.accountManager.deleteUser(user: firebaseUser) { success in
                    guard success else {
                        completion(false)
                        return
                    }
                    completion(true)
                }
            }
        }
    }
    
    func signOut(completion: @escaping ((Bool)->Void)) {
        do {
            try auth.signOut()
            completion(true)
        } catch {
            completion(false)
        }
    }
    
    
    func getUserReports(completion: @escaping ((Result<[Report], Error>)->Void)) {
        guard uid != nil else {
            completion(.failure(UserReportsError.error("The current user is no longer signed in.")))
            signOut { _ in }
            return
        }
        userReportsDelegate?.getUserReports() { status in
            switch status {
            case .success(let reports):
                completion(.success(reports))
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }
    
    private func setupUserListener() {
        Auth.auth().addStateDidChangeListener { auth, user in
            if !(user == nil) {
                self.userIsSignedIn = true
                self.currentUser = user
                self.getUserData()
            } else {
                self.userIsSignedIn = false
                self.currentUser = nil
                self.firebaseUser = nil
            }
        }
    }
}

//MARK: - FirebaseUserDelegate
extension UserViewModel: FirebaseUserDelegate {
    func save(completion: @escaping ((Bool) -> Void)) {
        
    }
    
    var notifyOfTheft: Bool {
        get {
            firebaseUser.notificationSettings.notifyOfTheft
        }
        set {
            firebaseUser.notificationSettings.notifyOfTheft = newValue
        }
    }
    
    var notifyOfWitness: Bool {
        get {
            firebaseUser.notificationSettings.notifyOfWitness
        }
        set {
            firebaseUser.notificationSettings.notifyOfTheft = newValue
        }
    }
    
    var notifyOfFound: Bool {
        get {
            firebaseUser.notificationSettings.notifyOfFound
        }
        set {
            firebaseUser.notificationSettings.notifyOfFound = newValue
        }
    }
    
    var notificationRadius: Double {
        get {
            firebaseUser.notificationSettings.notificationRadius
        }
        set {
            firebaseUser.notificationSettings.notificationRadius = newValue
        }
    }
    
    var uid: String? {
        auth.currentUser?.uid
    }
}

enum UserReportsError: Error {
    case error(String)
}

