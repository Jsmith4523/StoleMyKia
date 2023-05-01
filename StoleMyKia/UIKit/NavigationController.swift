//
//  CameraSession.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 5/1/23.
//

import Foundation
import UIKit
import SwiftUI

struct CustomNavView<C: View>: UIViewControllerRepresentable {
    
    let view: ()->C
    let statusBarColor: UIStatusBarStyle
    let backgroundColor: UIColor
    
    init(statusBarColor: UIStatusBarStyle, backgroundColor: Color, view: @escaping ()->C) {
        self.view            = view
        self.statusBarColor  = statusBarColor
        self.backgroundColor = UIColor(backgroundColor)
    }
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let navigationController = NavController(view: view,
                                                 statusBarColor: .lightContent,
                                                 backgroundColor: backgroundColor)
        
        return navigationController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
    
    typealias UIViewControllerType = UINavigationController
    
    private class NavController<C: View>: UINavigationController {
        
        var statusBarColor: UIStatusBarStyle!
        
        init(view: @escaping () -> C, statusBarColor: UIStatusBarStyle, backgroundColor: UIColor!) {
            super.init(rootViewController: UIHostingController(rootView: view()))
            self.statusBarColor = statusBarColor
            
            let appearance                 = UINavigationBarAppearance()
            appearance.backgroundColor     = backgroundColor
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            
            self.navigationBar.scrollEdgeAppearance = appearance
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override var preferredStatusBarStyle: UIStatusBarStyle {
            return statusBarColor
        }
    }
}


