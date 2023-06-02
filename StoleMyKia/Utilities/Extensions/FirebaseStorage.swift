//
//  FirebaseStorage.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/2/23.
//

import Foundation
import FirebaseStorage

extension Storage {
    
    private var vehicleImagesReference: StorageReference {
        self.reference(withPath: "/vehicles")
    }
    
    ///Deletes the vehicle image associated with the report.
    static func deleteVehicleImage(_ url: String?, completion: @escaping (Result<Bool, RMError>) -> Void) {
        
        guard !(url == nil) else {
            completion(.success(true))
            return
        }
        
        Storage.storage().vehicleImagesReference.delete { err in
            guard err == nil else {
                completion(.failure(.deletionError))
                return
            }
            
            completion(.success(true))
        }
    }
    
    ///Uploads the vehicles image to storage associated with the report UUID.
    static func setVehicleImage(to path: UUID, _ image: UIImage?, completion: @escaping (Result<String?, RMError>) -> Void) {
        
        guard let image else {
            completion(.success(nil))
            return
        }
        
        guard let imageData = image.pngData() else {
            completion(.failure(.error("Image Data error")))
            return
        }
        
        let imageReference = Storage.storage().vehicleImagesReference.child(path.uuidString)
        
        imageReference.putData(imageData) { meta, err in
            guard err == nil else {
                completion(.failure(.uploadImageError))
                return
            }
            
            imageReference.downloadURL { url, err in
                guard let url, err == nil else {
                    completion(.failure(.uploadImageError))
                    return
                }
                
                completion(.success(url.absoluteString))
            }
        }
    }
}

extension StorageReference {
    
}
