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

final class NotificationViewModel: NSObject, NotificationRadiusDelegate, ObservableObject {
    
    var currentRadius: CLLocationDistance?
    
    @Published var authorizationStatus: UNAuthorizationStatus!
    
    @AppStorage("notifyOfTheft") var notifyOfTheft = true
    @AppStorage("notifyOfWitness") var notifyOfWitness = true
    @AppStorage("notifyOfFound") var notifyOfFound = true
    
    @AppStorage("notificationRadius") var notificationRadius: Double?
    
    var notificationsAreAllowed: Bool {
        if let status = self.authorizationStatus, status.isAuthorized {
            return true
        }
        return false
    }

    private let notificationCenter = UNUserNotificationCenter.current()
    
    override init() {
        super.init()
        
        notificationCenter.delegate = self
        self.getNotificaitonAuthStatus()
    }
    
    func getNotificaitonAuthStatus() {
        notificationCenter.getNotificationSettings { status in
            self.authorizationStatus = status.authorizationStatus
        }
    }
}


extension NotificationViewModel: UNUserNotificationCenterDelegate {
    
    
}
