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
    
    @AppStorage("notifyOfTheft") var notifyOfTheft = true
    @AppStorage("notifyOfWitness") var notifyOfWitness = true
    @AppStorage("notifyOfFound") var notifyOfFound = true
    
    @AppStorage("notificationRadius") var notificationRadius = 25000.0
    
    var notificationsAreAllowed: Bool {
        var isAllowed = false
        
        notificationCenter.getNotificationSettings { status in
            switch status.authorizationStatus {
            case .authorized:
                isAllowed = true
            case .provisional:
                isAllowed = true
            case .ephemeral:
                isAllowed = true
            default:
                self.requestNotificationPermission()
                isAllowed = false
            }
        }
        
        return isAllowed
    }

    private let notificationCenter = UNUserNotificationCenter.current()
    
    override init() {
        super.init()
        notificationCenter.delegate = self
        requestNotificationPermission()
    }
    
    func requestNotificationPermission() {
        notificationCenter.requestAuthorization(options: [.sound, .alert, .badge]) { status, err in
            if let err {
                fatalError(err.localizedDescription)
            }
        }
    }
}

//MARK: - UNUserNotificationCenterDelegate
extension NotificationViewModel: UNUserNotificationCenterDelegate {
    
    
}

//MARK: - NotificationRadiusDelegate
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
