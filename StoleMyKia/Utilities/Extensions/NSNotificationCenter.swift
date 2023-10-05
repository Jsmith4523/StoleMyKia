//
//  NSNotificationCenter.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 8/17/23.
//

import Foundation

extension NSNotification.Name {
    
    static let deviceFCMToken = NSNotification.Name("deviceFCMToken")
    static let signOut = NSNotification.Name("signOut")
}

extension Notification {
    static let signOut = Foundation.Notification(name: .signOut,
                                      object: nil,
                                      userInfo: nil)
}
