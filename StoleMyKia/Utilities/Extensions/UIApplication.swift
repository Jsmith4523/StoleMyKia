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
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    ///The name of the application (subject to change LOL)
    static var appName: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
    }
}
