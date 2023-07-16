//
//  StorageManager.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 7/9/23.
//

import Foundation
import FirebaseStorage

enum StorageManagerError: Error {
    case imageDataError
    case imageUrlError
    case error(String)
}

class StorageManager {
    
    ///Shared instance
    static var shared = StorageManager()
    
    private init() {}
    
    private var reference: StorageReference {
        Storage.storage().reference(withPath: "Vehicles")
    }
    
    ///Deletes the vehicle image associated with the report.
    func deleteVehicleImage(path: String) async throws {        
        try await reference.child(path).delete()
    }
    
    ///Uploads the vehicles image to storage associated with the report UUID.
    func saveVehicleImage(_ image: UIImage?, to path: String) async throws -> String? {
        guard let image else { return nil }
        
        guard let imageData = image.pngData() else {
            throw StorageManagerError.imageDataError
        }
        
        let uploadTask = try await reference.child(path).putDataAsync(imageData)
        
        guard let url = try await uploadTask.storageReference?.downloadURL() else {
            throw StorageManagerError.imageUrlError
        }
        
        return url.absoluteString
    }
}
