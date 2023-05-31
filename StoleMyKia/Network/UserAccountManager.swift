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
    case snapshotError
    case createNewUserError
    case error(String)
}

class UserAccountManager {
    
    private let db = Database.database()
    
    private var reference: DatabaseReference {
        db.reference(withPath: "/users/")
    }
    
    func saveAccountChanges(user: FirebaseUser, completion: @escaping (Bool) -> Void) {
        do {
            let decodedData = try JSONEncoder().encode(user)
            let serializedUser = try JSONSerialization.jsonObject(with: decodedData)
            
            self.reference.child(user.uid).setValue(serializedUser) { err, ref in
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
    
    func getUserData(_ uid: String, completion: @escaping (Result<FirebaseUser, UAAccountError>) -> Void) {
        self.reference.child(uid).getData { err, snapshot in
            guard (err == nil) else {
                completion(.failure(UAAccountError.error(err?.localizedDescription ?? "There was an error")))
                return
            }
            
            guard let snapshot, snapshot.exists() else {
                completion(.failure(.snapshotError))
                return
            }

            guard let value = snapshot.value else {
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
    
    func userDataIsSaved(uid: String, completion: @escaping (Bool) -> Void) {
        self.reference.child(uid).getData { err, snapshot in
            guard let snapshot, snapshot.exists(), err == nil else {
                completion(false)
                return
            }
            
            completion(true)
        }
    }
    
    func createUserData(with uid: String, completion: @escaping (Result<Bool, UAAccountError>) -> Void) {
        do {
            let firebaseUser = FirebaseUser(uid: uid)
            let encodedUser = try JSONEncoder().encode(firebaseUser)
            let serializedUseer = try JSONSerialization.jsonObject(with: encodedUser)
            
            self.reference.child(uid).setValue(serializedUseer) { err, ref in
                guard err == nil else {
                    completion(.failure(.createNewUserError))
                    return
                }
                
                completion(.success(true))
            }
        } catch {
            completion(.failure(.createNewUserError))
        }
    }
    
    func deleteUser(user: FirebaseUser, completion: @escaping (Bool) -> Void) {
        self.reference.child(user.uid).removeValue { err, ref in
            guard (err == nil) else {
                completion(false)
                return
            }
            
            completion(true)
        }
    }
}
