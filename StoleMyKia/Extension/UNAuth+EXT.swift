//
//  UNNotification+EXT.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/13/23.
//

import Foundation
import UserNotifications

extension UNAuthorizationStatus {
    
    var isAuthorized: Bool {
        self == .authorized
    }
}
