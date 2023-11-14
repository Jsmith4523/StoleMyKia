//
//  UISheetPC.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 5/3/23.
//

import Foundation
import SwiftUI
import UIKit

extension [UISheetPresentationController.Detent] {
    
    static var timelineMapDetailDetents: Self {
        return [
            .custom(resolver: {_ in return CGFloat(200) }),
            .custom(resolver: {_ in return CGFloat(500) }),
        ]
    }
    
    static var timelineMapListDetents: Self {
        return [
            .custom(resolver: {_ in return CGFloat(750) }),
        ]
    }
}

extension View {
    
    func customSheetView<Content: View>(isPresented: Binding<Bool>, detents: [UISheetPresentationController.Detent] = [.medium()], showsIndicator: Bool = false, cornerRadius: CGFloat = 15, @ViewBuilder child: @escaping ()->Content) -> some View {
        return self
            .background {
                CustomSheetView(isPresented: isPresented, detents: detents, showsIndicator: showsIndicator, cornerRadius: cornerRadius, child: child)
            }
    }
}
 
///Use View extension .customSheetView for SwiftUI views
fileprivate struct CustomSheetView<Content: View>: UIViewControllerRepresentable {
    
    @Binding var isPresented: Bool
    
    let detents: [UISheetPresentationController.Detent]
    let showsIndicator: Bool
    let cornerRadius: CGFloat
    let child: () -> Content
        
    func makeUIViewController(context: Context) -> UIViewController {
        return UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        if isPresented {
            let hosting = DetentiveController(
                detents: self.detents,
                showIndicator: self.showsIndicator,
                cornerRadius: self.cornerRadius,
                content: self.child
            )
            
            uiViewController.present(hosting, animated: true) {
                DispatchQueue.main.async {
                    self.isPresented.toggle()
                }
            }
        }
    }
    
    private class DetentiveController<Content: View>: UIHostingController<Content> {
        
        let detents: [UISheetPresentationController.Detent]
        let showIndicator: Bool
        let cornerRadius: CGFloat
        let content: () -> Content
                
        init(detents: [UISheetPresentationController.Detent], showIndicator: Bool, cornerRadius: CGFloat, content: @escaping ()->Content) {
            self.detents        = detents
            self.showIndicator  = showIndicator
            self.cornerRadius   = cornerRadius
            self.content        = content
            
            super.init(rootView: content())
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            if let sheetController = sheetPresentationController {
                sheetController.detents               = self.detents
                sheetController.prefersGrabberVisible = self.showIndicator
                sheetController.preferredCornerRadius = self.cornerRadius
            }
        }
    }
}
