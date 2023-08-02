//
//  View+EXT.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/15/23.
//

import Foundation
import SwiftUI
import UIKit

extension UINavigationController {
    
    open override func viewDidLoad() {
        self.navigationBar.topItem?.backButtonDisplayMode = .minimal
    }
}

extension Text {
    
    func customTitleStyle() -> some View {
        return self
            .font(.system(size: 32).bold())
            .multilineTextAlignment(.center)
    }
    
    func customSubtitleStyle() -> some View {
        return self
            .font(.system(size: 16))
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
    }
}

extension View {
    
    func loginTextFieldStyle() -> some View {
        return self
            .padding()
            .background(Color(uiColor: .systemBackground))
            .overlay {
                Rectangle()
                    .stroke(Color.gray.opacity(0.4), lineWidth: 0.5)
            }
    }
    
    func imagePicker(isPresented: Binding<Bool>, selectedImage: Binding<UIImage?>, sourceType: UIImagePickerController.SourceType) -> some View {
        return self
            .sheet(isPresented: isPresented) { PhotoPicker(selectedImage: selectedImage, source: sourceType) }
    }
    
    func imagePicker(source: Binding<UIImagePickerController.SourceType?>, image: Binding<UIImage?>) -> some View {
        return self
            .sheet(item: source) { source in
                PhotoPicker(selectedImage: image, source: source)
                //Preventing white space at the bottom of the modal...
                    .ignoresSafeArea()
            }
    }
    
    func customSheetView<Content: View>(isPresented: Binding<Bool>, detents: [UISheetPresentationController.Detent] = [.medium()], showsIndicator: Bool = false, cornerRadius: CGFloat = 15, @ViewBuilder child: @escaping ()->Content) -> some View {
        return self
            .background {
                CustomSheetView(isPresented: isPresented, detents: detents, showsIndicator: showsIndicator, cornerRadius: cornerRadius, child: child)
            }
    }
    
    //TODO: Crete privacy policy
    func privacyPolicy(isPresented: Binding<Bool>) -> some View {
        return self
            .safari(isPresented: isPresented, url: URL(string: "https://www.google.com")!)
    }
    
    func safari(isPresented: Binding<Bool>, url: URL) -> some View {
        return self
            .sheet(isPresented: isPresented) { SafariView(url: url).ignoresSafeArea() }
    }
    
    func twitterSupport(isPresented: Binding<Bool>) -> some View {
        return self
            .safari(isPresented: isPresented, url: URL.twitterSupportURL)
    }
}
