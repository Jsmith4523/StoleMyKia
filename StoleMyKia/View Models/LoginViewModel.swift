//
//  LoginViewModel.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/25/23.
//

import Foundation
import FirebaseAuth

final class LoginViewModel: ObservableObject {
        
    @Published var isUserSignedIn = false
            
    private let auth = Auth.auth()
    
    private var isSignedIn: Void {
        self.isUserSignedIn = !(auth.currentUser == nil)
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
    
    func verifyResetPasscode(code: String, completion: @escaping (Bool?)->Void) {
        auth.verifyPasswordResetCode(code) { _, err in
            guard err == nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    func signUp(email: String, password: String, completion: @escaping (Bool?)->Void) {
        auth.createUser(withEmail: email, password: password) { result, err in
            guard result != nil, err == nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
}
