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
    
    func signIn(email: String, password: String) {
        auth.signIn(withEmail: email, password: password) { result, err in
            guard result != nil, err == nil else {
                return
            }
        }
    }
    
    func signUp(email: String, password: String) {
        auth.createUser(withEmail: email, password: password) { result, err in
            guard result != nil, err == nil else {
                return
            }
        }
    }
}
