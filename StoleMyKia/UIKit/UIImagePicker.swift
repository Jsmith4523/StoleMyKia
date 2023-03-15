//
//  UIImagePicker.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/15/23.
//

import Foundation
import SwiftUI
import UIKit

struct PhotoPicker: UIViewControllerRepresentable {
    
    @Binding var selectedImage: UIImage?
    @Binding var source: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker           = UIImagePickerController()
        imagePicker.sourceType    = source
        imagePicker.allowsEditing = true
        imagePicker.delegate      = context.coordinator
        
        return imagePicker
    }
    
    func makeCoordinator() -> PhotoPickerCoordinator {
        PhotoPickerCoordinator()
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        if let image = context.coordinator.image {
            self.selectedImage = image
        }
    }
    
    typealias UIViewControllerType = UIImagePickerController
    
    final class PhotoPickerCoordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        var image: UIImage?
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage {
                self.image = image
            }
            
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
