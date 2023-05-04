//
//  LoginViewModel.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/25/23.
//

import Foundation
import FirebaseAuth

@MainActor
final class UserViewModel: ObservableObject {
        
    @Published var showLoginProgressView = true
    @Published var userIsSignedIn = false
    
    @Published private(set) var currentUser: User!
            
    private let auth = Auth.auth()
    
    weak var userReportsDelegate: UserReportsDelegate?
    
    init() {
        Auth.auth().addStateDidChangeListener { auth, user in
            if !(user == nil) {
                self.userIsSignedIn = true
                self.currentUser = user
            } else {
                print("User is not signed in")
                self.userIsSignedIn = false
                self.currentUser = nil
            }
        }
    }
    
    func getUserCreationDate() -> Date? {
        guard let date = currentUser.metadata.creationDate else {
            return nil
        }
        
        return date
    }
    
    func getUserDisplayName() -> String? {
        guard let name = currentUser.displayName else {
            return nil
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
        //TODO: Delete reports made by the user
        auth.currentUser?.delete { err in
            guard err == nil else {
                print("❌ Error deleting user account: \(err!.localizedDescription)")
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    func signOut() throws {
        try? auth.signOut()
    }
    
    
    func getUserReports(completion: @escaping ((Result<[Report], Error>)->Void)) {
        guard let uid else {
            completion(.failure(UserReportsError.error("The current user is no longer signed in.")))
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
}

//MARK: - FirebaseUserDelegate
extension UserViewModel: FirebaseUserDelegate {
    var uid: String? {
        auth.currentUser?.uid
    }
}

enum UserReportsError: Error {
    case error(String)
}

protocol UserReportsDelegate: AnyObject {
    
    func getUserReports(completion: @escaping ((Result<[Report], Error>)->Void))
}
