//
//  UIImagePicker.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/15/23.
//

import Foundation
import SwiftUI
import UIKit

extension View {
    
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
}

struct PhotoPicker: UIViewControllerRepresentable {
    
    @Binding var selectedImage: UIImage?
    var source: UIImagePickerController.SourceType
        
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker           = UIImagePickerController()
        imagePicker.sourceType    = source
        imagePicker.allowsEditing = true
        imagePicker.delegate      = context.coordinator
        
        return imagePicker
    }
    
    func makeCoordinator() -> PhotoPickerCoordinator {
        return PhotoPickerCoordinator(photoPicker: self)
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }
    
    typealias UIViewControllerType = UIImagePickerController
    
    final class PhotoPickerCoordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ObservableObject {
        
        var photoPicker: PhotoPicker
        
        init(photoPicker: PhotoPicker) {
            self.photoPicker = photoPicker
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage {
                self.photoPicker.selectedImage = image
            }
            
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}


extension UIImagePickerController.SourceType: Identifiable {
    
    public var id: Int {
        self.rawValue
    }
}
