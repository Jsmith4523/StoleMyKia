//
//  InteractiveSheet.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/16/23.
//

import Foundation
import SwiftUI
import UIKit

extension View {
        
    func backgroundInteractiveSheet<C: View>(isPresented: Binding<Bool>, cornerRadius: CGFloat = 15, detents: [UISheetPresentationController.Detent] = [.medium(), .large()], @ViewBuilder view: @escaping () -> C) -> some View {
        return self
            .background {
                InteractiveSheetView(isPresented: isPresented, view: view, cornerRadius: cornerRadius, detents: detents)
            }
    }
}

struct InteractiveSheetView<C: View>: UIViewControllerRepresentable {
    
    @Binding var isPresented: Bool
    
    let view: () -> C
    let cornerRadius: CGFloat
    let detents: [UISheetPresentationController.Detent]
    
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented {
            let interactiveVC = InteractiveSheetViewController(detents: detents, cornerRadius: cornerRadius, view: view)
            
            uiViewController.present(interactiveVC, animated: true) {
                DispatchQueue.main.async {
                    self.isPresented = false
                }
            }
        }
    }
}

fileprivate class InteractiveSheetViewController<C: View>: UIHostingController<C> {
    
    ///When passed, the last detent in the array will override background interaction. If the first detent is large, then it is ignored.
    private let detents: [UISheetPresentationController.Detent]
    private let cornerRadius: CGFloat
    
    init(detents: [UISheetPresentationController.Detent], cornerRadius: CGFloat, view: @escaping () -> C) {
        self.detents = detents
        self.cornerRadius = cornerRadius
        super.init(rootView: view())
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSheetController()
    }
    
    private func setupSheetController() {
        if let pc = self.sheetPresentationController {
            pc.largestUndimmedDetentIdentifier = .medium
            pc.largestUndimmedDetentIdentifier = detents.last?.identifier
            pc.detents = self.detents
            pc.preferredCornerRadius = self.cornerRadius
            pc.prefersGrabberVisible = true
        }
    }
}
