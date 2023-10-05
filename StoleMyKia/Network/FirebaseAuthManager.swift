//
//  FirebaseAuthManager.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 8/4/23.
//

import Foundation
import FirebaseAuth

class FirebaseAuthManager {
    
    enum FirebaseAuthManagerError: Error {
        case verificationIdError
        case userDoesNotExist
        case userAlreadyExist
        case error
    }
    
    private let auth = Auth.auth()
    
    private var verificationId: String?
    
    ///Shared instance
    static let manager = FirebaseAuthManager()
    
    private init() {}
    
    /// Authenticate with users phone number
    /// - Parameter phoneNumber: The users phone number
    public func authWithPhoneNumber(_ phoneNumber: String) async throws {        
        let verificationId = try await PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil)
        self.verificationId = verificationId
    }
    
    public func verifyCode(_ code: String) async throws {
        guard let verificationId else {
            throw FirebaseAuthManagerError.verificationIdError
        }
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId, verificationCode: code)
        try await auth.signIn(with: credential)
    }
    
    public func signOutUser() throws {
        try auth.signOut()
    }
}
