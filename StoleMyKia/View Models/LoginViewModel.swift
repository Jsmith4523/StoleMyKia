//
//  LoginViewModel.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/25/23.
//

import Foundation
import FirebaseAuth

@MainActor
final class LoginViewModel: ObservableObject {
        
    @Published var userIsSignedIn = false
            
    private let auth = Auth.auth()
    
    init() {
        Auth.auth().addStateDidChangeListener { auth, user in
            if !(user == nil) {
                print("User is signed in: uid \(user?.uid)")
                self.userIsSignedIn = true
            } else {
                print("User is not signed in")
                self.userIsSignedIn = false
            }
        }
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
}
