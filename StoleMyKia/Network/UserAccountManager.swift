//
//  UserAccountManager.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 5/7/23.
//

import Foundation
import Firebase

enum UAAccountError: Error {
    case doesNotExist
    case decodingError
    case encodingError
    case error(String)
}

class UserAccountManager {
    
    private let db = Database.database()
    
    func saveAccountChanges(user: FirebaseUser, completion: @escaping (Bool) -> Void) {
        do {
            let decodedData = try JSONEncoder().encode(user)
            let serializedUser = try JSONSerialization.jsonObject(with: decodedData)
            
            db.reference(withPath: "/users").child(user.uid).setValue(serializedUser) { err, ref in
                guard err == nil else {
                    print("❌ \(err?.localizedDescription ?? "There was an error saving account changes")")
                    return
                }
                completion(true)
            }
        } catch {
            completion(false)
        }
    }
    
    func getUserData(_ uid: String, completion: @escaping (Result<FirebaseUser, Error>) -> Void) {
        db.reference(withPath: "/users/").child(uid).getData { err, snapshot in
            guard (err == nil) else {
                completion(.failure(UAAccountError.error(err?.localizedDescription ?? "There was an error")))
                return
            }

            guard let value = snapshot?.value else {
                completion(.failure(UAAccountError.doesNotExist))
                return
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: value)
                let user = try JSONDecoder().decode(FirebaseUser.self, from: jsonData)
                completion(.success(user))
            } catch {
                completion(.failure(UAAccountError.decodingError))
            }
        }
    }
    
    func deleteUser(user: FirebaseUser, completion: @escaping (Bool) -> Void) {
        db.reference(withPath: "/users").child(user.uid).removeValue { err, ref in
            guard (err == nil) else {
                completion(false)
                return
            }
            
            completion(true)
        }
    }
}
