//
//  SFSafariView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/15/23.
//

import Foundation
import SafariServices
import UIKit
import SwiftUI


struct SafariView: UIViewControllerRepresentable {
    
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let safariView = SFSafariViewController(url: url)
        safariView.preferredControlTintColor = .tintColor
        safariView.dismissButtonStyle = .close
        
        return safariView
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
    
    typealias UIViewControllerType = SFSafariViewController
    
}
