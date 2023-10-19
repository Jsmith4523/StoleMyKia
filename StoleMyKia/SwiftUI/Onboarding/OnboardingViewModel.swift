//
//  OnboardingViewModel.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/18/23.
//

import Foundation
import CoreLocation
import NotificationCenter

final class OnboardingViewModel: NSObject, ObservableObject {
    
    func requestNotificationAccess() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .criticalAlert, .alert]) { _, _ in}
    }
    
    func requestLocationServicesAccess() {
        CLLocationManager.shared.requestAlwaysAuthorization()
    }
}
