//
//  View+EXT.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/15/23.
//

import Foundation
import SwiftUI
import UIKit

extension View {
    
    func imagePicker(isPresented: Binding<Bool>, selectedImage: Binding<UIImage?>, sourceType: Binding<UIImagePickerController.SourceType>) -> some View {
        return self
            .sheet(isPresented: isPresented) { PhotoPicker(selectedImage: selectedImage, source: sourceType) }
    }
    
    //TODO: Crete privacy policy
    func privacyPolicy(isPresented: Binding<Bool>) -> some View {
        return self
            .sheet(isPresented: isPresented) { SafariView(url: URL(string: "https://www.google.com")!).ignoresSafeArea() }
    }
    
    func safari(isPresented: Binding<Bool>, url: URL) -> some View {
        return self
            .sheet(isPresented: isPresented) { SafariView(url: url).ignoresSafeArea() }
    }
}
