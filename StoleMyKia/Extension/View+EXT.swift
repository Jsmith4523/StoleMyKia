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

extension View {
    
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
}
