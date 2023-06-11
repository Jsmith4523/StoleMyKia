//
//  FirebaseUserDelegate.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 5/28/23.
//

import Foundation

protocol FirebaseUserDelegate: AnyObject {
    var uid: String? {get}
    var updates: [UUID]? {get}
    var bookmarks: [UUID]? {get}
    var notifyOfTheft: Bool {get set}
    var notifyOfWitness: Bool {get set}
    var notifyOfFound: Bool {get set}
    var notificationRadius: Double {get set}
    
    
    func save(completion: @escaping ((Bool)->Void))
    
    ///Adds an notification to the user database reference
    func addRemoteNotification(_ notification: FirebaseUserNotification)
}
