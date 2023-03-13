//
//  NotificationViewModel.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/13/23.
//

import Foundation
import NotificationCenter
import MapKit
import SwiftUI

final class NotificationViewModel: NSObject, ObservableObject {

    @Published var authorizationStatus: UNAuthorizationStatus!
    
    @AppStorage("notifyOfTheft") var notifyOfTheft = true
    @AppStorage("notifyOfWitness") var notifyOfWitness = true
    @AppStorage("notifyOfFound") var notifyOfFound = true
    
    @AppStorage("notificationRadius") var notificationRadius = 25000.0
    
    var notificationsAreAllowed: Bool {
        guard let status = self.authorizationStatus, status.isAuthorized else {
            return false
        }
        return true
    }

    private let notificationCenter = UNUserNotificationCenter.current()
    
    override init() {
        super.init()
        
        notificationCenter.delegate = self
        self.getNotificaitonAuthStatus()
    }
    
    func getNotificaitonAuthStatus() {
        notificationCenter.getNotificationSettings { status in
            DispatchQueue.main.async {
                self.authorizationStatus = status.authorizationStatus
            }
        }
    }
}


extension NotificationViewModel: UNUserNotificationCenterDelegate {
    
    
}

extension NotificationViewModel: NotificationRadiusDelegate {
    var currentRadius: CLLocationDistance? {
        get {
            notificationRadius
        }
        set {
            if let newValue {
                self.notificationRadius = newValue
            }
        }
    }
}
