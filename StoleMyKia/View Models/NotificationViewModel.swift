//
//  NotificationViewModel.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/13/23.
//

import Foundation
import NotificationCenter
import Firebase
import MapKit
import SwiftUI


final class NotificationViewModel: NSObject, ObservableObject {
    
    weak var firebaseUserDelegate: FirebaseUserDelegate?
    
    func setDelegate(_ delegate: FirebaseUserDelegate) {
        self.firebaseUserDelegate = delegate
    }
        
    override init() {
        super.init()
    }
    
    func requestNotificationCenterAccess() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .carPlay, .criticalAlert]) { success, err in
            guard success, err == nil else {
                return
            }
        }
    }
}
