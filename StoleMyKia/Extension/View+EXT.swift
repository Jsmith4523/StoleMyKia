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
            .sheet(isPresented: isPresented) {
                PhotoPicker(selectedImage: selectedImage, source: sourceType)
            }
    }
}
