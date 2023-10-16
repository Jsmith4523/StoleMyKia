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
    
    private let hostingController: UIHostingController<C>
    
    init(statusBarStyle: UIStatusBarStyle = .default, @ViewBuilder rootView: @escaping () -> C) {
        self.hostingController = HostingController(statusBarStyle: statusBarStyle) { rootView() }
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        hostingController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
        
    final private class HostingController: UIHostingController<C> {
        
        var statusBarStyle: UIStatusBarStyle
        
        init(statusBarStyle: UIStatusBarStyle, rootView: @escaping () -> C) {
            self.statusBarStyle = statusBarStyle
            super.init(rootView: rootView())
            setupSheetInteraction()
        }
        
        @MainActor required dynamic init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupSheetInteraction() {
            self.sheetPresentationController?.largestUndimmedDetentIdentifier = .medium
            self.sheetPresentationController?.detents = [.medium(), .large()]
        }
        
        override var preferredStatusBarStyle: UIStatusBarStyle {
            return statusBarStyle
        }
        
        deinit {
            print("Dead: HostingController")
        }
    }
}
