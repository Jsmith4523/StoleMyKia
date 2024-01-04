//
//  UIHostingController.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/12/23.
//

import Foundation
import SwiftUI
import UIKit

///Enables status bar style changes to the swiftui view for deployments targets lower than iOS 16.0
struct HostingView<C: View>: UIViewControllerRepresentable {
    
    private let rootView: () -> C
    private var statusBarStyle: UIStatusBarStyle
    
    init(statusBarStyle: UIStatusBarStyle = .default, @ViewBuilder rootView: @escaping () -> C) {
        self.statusBarStyle = statusBarStyle
        self.rootView = rootView
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let hostingController = HostingController(statusBarStyle: statusBarStyle, rootView: rootView)
        return hostingController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
       
    }
        
    final private class HostingController: UIHostingController<C> {
        
        var statusBarStyle: UIStatusBarStyle
        
        init(statusBarStyle: UIStatusBarStyle, rootView: @escaping () -> C) {
            self.statusBarStyle = statusBarStyle
            super.init(rootView: rootView())
            //setupNavigationTitle()
        }
        
        @MainActor required dynamic init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupNavigationTitle() {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = .black
            self.navigationController?.navigationBar.standardAppearance = appearance
        }
        
        override var preferredStatusBarStyle: UIStatusBarStyle {
            return .lightContent
        }
        
        deinit {
            print("Dead: HostingController")
        }
    }
}
