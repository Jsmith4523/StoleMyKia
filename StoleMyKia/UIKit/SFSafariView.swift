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

extension View {
    
    func safari(isPresented: Binding<Bool>, url: URL) -> some View {
        return self
            .sheet(isPresented: isPresented) { SafariView(url: url).ignoresSafeArea() }
    }
}

struct SafariView: UIViewControllerRepresentable {
    
    let url: URL?
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let safariView = SFSafariViewController(url: url ?? URL(string: "www.google.com/StoleMyKia")!)
        safariView.preferredControlTintColor = .systemBlue
        safariView.dismissButtonStyle = .close
        
        return safariView
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
    
    typealias UIViewControllerType = SFSafariViewController
}
