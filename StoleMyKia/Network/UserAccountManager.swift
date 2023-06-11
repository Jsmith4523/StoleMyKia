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
        
    private var reference: DatabaseReference {
        Database.database().reference(withPath: "Users/")
    }
    
    func saveAccountChanges(user: FirebaseUser, completion: @escaping (Bool) -> Void) {
        guard let userData = try? JSONSerialization.createJsonFromObject(user) else {
            completion(false)
            return
        }
        
        self.reference.child(user.uid).setValue(userData) { err, ref in
            guard (err == nil) else {
                completion(false)
                return
            }
            completion(true)
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
            
            guard let user = try? JSONSerialization.createObjectWithData(FirebaseUser.self, jsonObject: value) else {
                completion(.failure(UAAccountError.decodingError))
                return
            }
            completion(.success(user))
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
    
    ///Creates new user data and sets up their notification reference
    func createUserData(with uid: String, completion: @escaping (Result<Bool, UAAccountError>) -> Void) {
        let user = FirebaseUser(uid: uid)
        
        guard let userData = try? JSONSerialization.createJsonFromObject(user) else {
            completion(.failure(.encodingError))
            return
        }
        
        //Initially setting the value to nil for setup...
//        DatabaseReference.notificationsReference.child(uid).setV { [weak self] err, reference in
//            guard err == nil else {
//                completion(.failure(.createNewUserError))
//                return
//            }
//            
//            self?.reference.child(uid).setValue(userData) { err, ref in
//                guard err == nil else {
//                    completion(.failure(.createNewUserError))
//                    return
//                }
//                completion(.success(true))
//            }
//        }
    }
    
    ///Saves a recieved FCM notification to the users notification reference
    func saveNotification(_ notification: FirebaseUserNotification) {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        
        guard let notificationData = try? JSONSerialization.createJsonFromObject(notification) else {
            print("Unable to create notification data")
            return
        }
        
        DatabaseReference.notificationsReference.child(currentUser.uid).setValue(notificationData)
    }
    
    func didSelectNotification(_ notificationId: UUID) {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        
        DatabaseReference.notificationsReference.child(currentUser.uid).getData { err, snapshot in
            guard let snapshot, let firebaseNotification = try? JSONSerialization.createObjectWithData(FirebaseUserNotification.self, jsonObject: snapshot.value) else {
                return
            }
            
            var notifcation = firebaseNotification
            notifcation.didRead = true
            
            guard let value = try? JSONSerialization.createJsonFromObject(notifcation) else {
                return
            }
            
            DatabaseReference.notificationsReference.setValue(value) { err, ref in
                guard (err == nil) else {
                    return
                }
                
                UIApplication.shared.applicationIconBadgeNumber -= 1
            }
        }
    }
    
    func removeNotification(_ notification: FirebaseUserNotification, completion: @escaping (Result<Bool, UAAccountError>) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(.failure(.error("There was an error with your account. Please log out and try again")))
            return
        }
        
        UIApplication.shared.applicationIconBadgeNumber -= 1
        
        DatabaseReference.notificationsReference.child(currentUser.uid).removeValue { err, snapshot in
            guard (err == nil) else {
                completion(.failure(.error("We were unable to remove your notification at this time. Try again later")))
                return
            }
            completion(.success(true))
        }
    }
    
    ///Deletes the user data and their notifications. This is a permanent!
    func deleteUser(user: FirebaseUser, completion: @escaping (Bool) -> Void) {
        DatabaseReference.notificationsReference.child(user.uid).removeValue { [weak self] err, ref in
            guard (err == nil) else {
                completion(false)
                return
            }
            
            self?.reference.child(user.uid).removeValue { err, ref in
                guard (err == nil) else {
                    completion(false)
                    return
                }
                completion(true)
            }
        }
    }
}
