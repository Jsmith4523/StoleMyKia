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
    
    func rootViewController() -> UIViewController? {
        let sceneDelegate = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive })?
            .delegate as? UIWindowSceneDelegate
        
        return (sceneDelegate?.window??.rootViewController)
    }
    
    func topViewController(of viewController: UIViewController? = nil) -> UIViewController? {
        guard let viewController = viewController ?? rootViewController() else { return nil }
        
        if let presentedViewController = viewController.presentedViewController {
            return topViewController(of: presentedViewController)
        }
        
        if let navigationController = viewController as? UINavigationController,
           let topViewController = navigationController.topViewController {
            return self.topViewController(of: topViewController)
        }
        
        if let tabBarController = viewController as? UITabBarController,
           let selectedViewController = tabBarController.selectedViewController {
            return topViewController(of: selectedViewController)
        }
        
        return viewController
    }
}
