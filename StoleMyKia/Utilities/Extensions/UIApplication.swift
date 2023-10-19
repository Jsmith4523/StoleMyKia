//
//  UIApplication.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/18/23.
//

import Foundation
import UIKit

extension UIApplication {
    
    ///The version of this application
    static var appVersion: String? {
        guard let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
            return "N/A"
        }
        return appVersion
    }
    
    ///The name of the application (subject to change LOL)
    static var appName: String? {
        guard let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String else {
            return "application"
        }
        return appName
    }
}
