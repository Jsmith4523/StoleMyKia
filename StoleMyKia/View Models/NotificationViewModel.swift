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
    
    @Published var notifyTheft = true
    @Published var notifyWitness = true
    @Published var notifyFound = true
    @Published var radius = 25000.0
    
    weak var firebaseUserDelegate: FirebaseUserDelegate?
    
    func setDelegate(_ delegate: FirebaseUserDelegate) {
        self.firebaseUserDelegate = delegate
    }
    
    var notificationsAreAllowed: Bool {
        var isAllowed = false
        
        notificationCenter.getNotificationSettings { [weak self] status in
            switch status.authorizationStatus {
            case .authorized:
                isAllowed = true
            case .provisional:
                isAllowed = true
            case .ephemeral:
                isAllowed = true
            default:
                self?.requestNotificationPermission()
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
    
    deinit {
        print("Dead: NotificationViewmodel")
    }
}

//MARK: - UNUserNotificationCenterDelegate
extension NotificationViewModel: UNUserNotificationCenterDelegate {
    
    
}

extension NotificationViewModel: MessagingDelegate {
    
    
}
