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
    
    @Published private(set) var isSignedIn = false
    
    
    //@Published private(set) var currentUser: User!
    @Published private(set) var firebaseUser: FirebaseUser!
    @Published private(set) var alertErrorLoggingIn = false
    
    private let accountManager = UserAccountManager()
            
    private let auth = Auth.auth()
    
    private weak var userReportsDelegate: UserReportsDelegate?
    
    init() {
        auth.addStateDidChangeListener { [weak self] _, user in
            if (user == nil) {
                self?.isSignedIn = false
                self?.firebaseUser = nil
            } else {
                self?.isSignedIn = true
                self?.getUserData()
            }
        }
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
        
        userReportsDelegate?.reportDoesExist(uuid: id) { [weak self] status in
            guard status == true else {
                completion(false)
                return
            }
            var user = firebaseUser
            user.addReportToBookmark(id)
            
            self?.saveChanges(user: user) { status in
                completion(status)
            }
        }
    }
    
    func removeBookmark(id: UUID, completion: @escaping (Bool) -> Void) {
        guard let firebaseUser else {
            completion(false)
            return
        }
        
        userReportsDelegate?.reportDoesExist(uuid: id) { [weak self] status in
            var user = firebaseUser
            user.removeReportFromBookmark(id)
            
            self?.saveChanges(user: user) { status in
                completion(status)
            }
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

