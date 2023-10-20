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
    
    enum OnboardingFeatureStatus {
        case authorized, disabled, notDetermined, error
    }
    
    @Published private(set) var notificationAuthStatus: OnboardingFeatureStatus = .notDetermined
    @Published private(set) var userLocationAuthStatus: OnboardingFeatureStatus = .notDetermined
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
    }

    func requestNotificationAccess() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .criticalAlert, .alert]) { [weak self] success, err in
            guard success, err == nil else {
                self?.notificationAuthStatus = .error
                return
            }
            self?.notificationAuthStatus = .authorized
        }
    }
    
    func requestLocationServicesAccess() {
        locationManager.requestAlwaysAuthorization()
    }
}

//MARK: CLLocationManagerDelegate
extension OnboardingViewModel: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways:
            self.userLocationAuthStatus = .authorized
        case .authorizedWhenInUse:
            self.userLocationAuthStatus = .authorized
        case .notDetermined:
            self.userLocationAuthStatus = .notDetermined
        default:
            self.userLocationAuthStatus = .disabled
        }
    }
}
