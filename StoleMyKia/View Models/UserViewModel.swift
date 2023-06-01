//
//  LoginViewModel.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/25/23.
//

import Foundation
import FirebaseAuth
import Firebase


final class UserViewModel: ObservableObject {
        
    @Published var showLoginProgressView = true
    @Published var userIsSignedIn = false
    
    //@Published private(set) var currentUser: User!
    @Published private(set) var firebaseUser: FirebaseUser!
    @Published private(set) var alertErrorLoggingIn = false
    
    private let accountManager = UserAccountManager()
            
    private let auth = Auth.auth()
    
    private weak var userReportsDelegate: UserReportsDelegate?
    
    init() {
        setupUserListener()
    }
    
    func setUserReportsDelegate(_ delegate: UserReportsDelegate) {
        self.userReportsDelegate = delegate
    }
    
    func currentUser() -> User! {
        auth.currentUser
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
        let oldFirebaseUser = self.firebaseUser
        
        accountManager.saveAccountChanges(user: user) { [weak self] status in
            //Setting the previous value of the user if false...
            guard status else {
                self?.firebaseUser = oldFirebaseUser
                return
            }
            
            self?.getUserData()
            completion(status)
        }
    }
    
    private func getUserData() {
        guard let currentUser = auth.currentUser else {
            return
        }
        
        self.accountManager.getUserData(currentUser.uid) { [weak self] result in
            switch result {
            case .success(let user):
                self?.firebaseUser = user
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func getUserDisplayName() -> String {
        return ""
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
        auth.createUser(withEmail: email, password: password) { [weak self] result, err in
            guard let result, err == nil else {
                completion(false)
                return
            }
            
            self?.accountManager.createUserData(with: result.user.uid) { result in
                switch result {
                case .success(_):
                    self?.setupUserListener()
                    completion(true)
                case .failure(let failure):
                    print(failure.localizedDescription)
                }
            }
        }
    }
    
    ///WARNING: Deletes the signed in users account entirely!
    func deleteAccount(completion: @escaping ((Bool?)->Void)) {
        guard let firebaseUser else {
            completion(false)
            return
        }
        
        userReportsDelegate?.deleteAll { [weak self] success in
            guard success else {
                completion(false)
                return
            }
            
            self?.auth.currentUser?.delete { [weak self] err in
                guard err == nil else {
                    print(err?.localizedDescription ?? "There was an error")
                    completion(false)
                    return
                }
                
                self?.accountManager.deleteUser(user: firebaseUser) { success in
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
    
    
    func getUserReports(completion: @escaping (Result<[Report], URReportsError>) -> Void) {
        userReportsDelegate?.getUserReports() { status in
            switch status {
            case .success(let reports):
                completion(.success(reports))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    func getUserBookmarks(completion: @escaping (Result<[Report], URReportsError>) -> Void) {
        userReportsDelegate?.getUserBookmarks(removalCompletion: { [weak self] uuid in
            self?.removeBookmark(id: uuid) { _ in }
        }, completion: { status in
            switch status {
            case .success(let reports):
                completion(.success(reports))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    func getUserUpdates(completion: @escaping (Result<[Report], URReportsError>) -> Void) {
        userReportsDelegate?.getUserUpdates { status in
            switch status {
            case .success(let reports):
                completion(.success(reports))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func setupUserListener() {
        print("Fired")
        Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            if let user {
                self?.accountManager.userDataIsSaved(uid: user.uid) { [weak self] success in
                    if success {
                        print("User is signed in")
                        self?.getUserData()
                        self?.userIsSignedIn = true
                    } else {
                        self?.firebaseUser = nil
                        self?.userIsSignedIn = false
                    }
                }
            } else {
                self?.firebaseUser = nil
                self?.userIsSignedIn = false
            }
        }
        
        func prepareToSignOut() {
            //FIXME:
            //try? self.auth.signOut()
            self.firebaseUser = nil
            self.userIsSignedIn = false
        }
        
        func pepareForSignIn(user: User) {
            self.userIsSignedIn = true
            self.getUserData()
        }
    }
    
    deinit {
        print("Dead: UserViewModel")
    }
}

//MARK: - FirebaseUserDelegate
extension UserViewModel: FirebaseUserDelegate {
    var updates: [UUID]? {
        guard let firebaseUser else {
            return nil
        }
        
        return firebaseUser.updates
    }
    
    var bookmarks: [UUID]? {
        guard let firebaseUser else {
            return nil
        }
       
        return firebaseUser.bookmarks
    }
    
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

