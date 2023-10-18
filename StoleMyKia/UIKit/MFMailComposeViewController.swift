//
//  MFMailComposeViewController.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 8/14/23.
//

import SwiftUI
import UIKit
import MessageUI

extension View {
    
    func emailComposerView(isPresented: Binding<Bool>, composeMode: ComposeMode = .issue) -> some View {
        return self
            .sheet(isPresented: isPresented) {
                EmailComposeView(composeMode: composeMode)
                    .edgesIgnoringSafeArea(.bottom)
            }
    }
    
    /// Hides the view conditionally if the device is not capable of sending an email.
    func canSendEmail() -> some View {
        ZStack {
            if MFMailComposeViewController.canSendMail() {
                self
            } else {
                EmptyView()
                    .hidden()
            }
        }
    }
}

enum ComposeMode: Identifiable {
    case feature
    case issue
    
    static let recipient = "studentlyko@gmail.com"
    
    var id: Self {
        return self
    }
    
    var subject: String {
        switch self {
        case .feature:
            return "StoleMyKia Feature Request"
        case .issue:
            return "Issue with StoleMyKia"
        }
    }
    
    var placeholderBody: String {
        switch self {
        case .feature:
            return "**Remove this text and tell us what new features and/or improve you would like to see!**"
        case .issue:
            return "**Remove this text and tell us what issues you're encountering! Please include your phone number if necessary.**"
        }
    }
}

struct EmailComposeView: UIViewControllerRepresentable {
    
    let composeMode: ComposeMode
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients([ComposeMode.recipient])
        vc.setSubject(composeMode.subject)
        vc.setMessageBody(composeMode.placeholderBody, isHTML: false)
        vc.delegate = context.coordinator
        return vc
    }
    
    func makeCoordinator() -> MailComposeCoordinator {
        MailComposeCoordinator()
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    class MailComposeCoordinator: NSObject, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate {
        
        private let ac: UIAlertController = {
            let ac = UIAlertController(title: "There was an error sending the email.",
                                       message: "Please try again.",
                                       preferredStyle: .alert)
            ac.addAction(.init(title: "OK", style: .default))
            return ac
        }()
        
        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            guard (result == .sent || result == .cancelled) else {
                controller.present(ac, animated: true)
                return
            }
            controller.dismiss(animated: true)
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            guard error == nil else {
                controller.present(ac, animated: true)
                return
            }
            controller.dismiss(animated: true)
        }
    }
}
