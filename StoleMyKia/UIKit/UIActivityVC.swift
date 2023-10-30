//
//  UIActivityVC.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/1/23.
//

import UIKit
import SwiftUI

extension View {
    
    func activityController(isPresented: Binding<Bool>, activityItems items: [Any]) -> some View {
        return self
            .background {
                if isPresented.wrappedValue {
                    ActivityController(isPresented: isPresented, items: items)
                }
            }
    }
}

fileprivate struct ActivityController: UIViewControllerRepresentable {
    
    @Binding var isPresented: Bool
    
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIViewController {
        return UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented {
            let vc =  UIActivityVC(activityItems: items, applicationActivities: nil)
            uiViewController.present(vc, animated: true) {
                DispatchQueue.main.async {
                    isPresented = false
                }
            }
        }
    }
    
    typealias UIViewControllerType = UIViewController
}

fileprivate final class UIActivityVC: UIActivityViewController {
        
    override init(activityItems: [Any], applicationActivities: [UIActivity]?) {
        super.init(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let sheetPresentationController {
            sheetPresentationController.detents = [.medium(), .large()]
            sheetPresentationController.prefersGrabberVisible = true
            sheetPresentationController.preferredCornerRadius = 25
        }
    }
}
