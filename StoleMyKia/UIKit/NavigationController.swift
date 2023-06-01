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
    let title: String
    
    init(title: String = "", statusBarColor: UIStatusBarStyle = .default, backgroundColor: Color = Color(uiColor: .systemBackground), @ViewBuilder view: @escaping ()->C) {
        self.view            = view
        self.statusBarColor  = statusBarColor
        self.backgroundColor = UIColor(backgroundColor)
        self.title           = title
    }
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let navigationController = NavController(view: view,
                                                 statusBarColor: .lightContent,
                                                 backgroundColor: backgroundColor,
                                                 title: title)
        
        return navigationController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
    
    typealias UIViewControllerType = UINavigationController
    
    private class NavController<C: View>: UINavigationController {
        
        var statusBarColor: UIStatusBarStyle!
        
        init(view: @escaping () -> C, statusBarColor: UIStatusBarStyle, backgroundColor: UIColor!, title: String) {
            super.init(rootViewController: UIHostingController(rootView: view()))
            self.statusBarColor = statusBarColor
            
            self.navigationBar.topItem?.title = title
            self.navigationController?.navigationBar.barTintColor = .white
            
            let appearance                 = UINavigationBarAppearance()
            appearance.backgroundColor     = backgroundColor
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            
            self.navigationBar.scrollEdgeAppearance        = appearance
            self.navigationBar.standardAppearance          = appearance
            self.navigationBar.compactAppearance           = appearance
            self.navigationBar.compactScrollEdgeAppearance = appearance
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override var preferredStatusBarStyle: UIStatusBarStyle {
            return statusBarColor
        }
        
        override func viewDidLoad() {
           print("I'm loaded")
           //super.viewDidLoad()
        }
        
        override func viewDidAppear(_ animated: Bool) {
            print("I'm appeared")
            super.viewDidAppear(animated)
        }
        
        override func viewDidDisappear(_ animated: Bool) {
            print("I disapeared")
            super.viewDidDisappear(animated)
        }
        
        deinit {
            print("I'm dead")
        }
    }
}
