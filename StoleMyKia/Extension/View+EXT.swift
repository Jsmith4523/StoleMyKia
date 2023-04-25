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
    
    open override func viewWillLayoutSubviews() {
        self.navigationBar.backItem?.backButtonDisplayMode = .minimal
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
    
    func imagePicker(isPresented: Binding<Bool>, selectedImage: Binding<UIImage?>, sourceType: Binding<UIImagePickerController.SourceType>) -> some View {
        return self
            .sheet(isPresented: isPresented) { PhotoPicker(selectedImage: selectedImage, source: sourceType) }
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
    
    func reportDetailView(isPresented: Binding<Bool>, cache: ImageCache, report: Report) -> some View {
        return self
            .sheet(isPresented: isPresented) {
                SelectedReportDetailView(imageCache: cache)
            }
    }
}
