//
//  UserDefaults.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 8/13/23.
//

import Foundation

extension UserDefaults {
    
    static let deviceIdentifierKey = "deviceID"

    func firebaseDeviceIdentifier() -> UUID {
        guard let deviceID = Self.standard.value(forKey: Self.deviceIdentifierKey) as? UUID else {
            createFirebaseDeviceIdentifier()
            return firebaseDeviceIdentifier()
        }
        return deviceID
    }
    
    ///Saves a new UUID value for identifying this device in Firebase
    private func createFirebaseDeviceIdentifier() {
        Self.standard.set(UUID(), forKey: Self.deviceIdentifierKey)
    }
}
