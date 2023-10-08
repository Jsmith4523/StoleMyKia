//
//  StorageManager.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 7/9/23.
//

import Foundation
import FirebaseStorage

class StorageManager {
    
    enum StorageManagerError: Error {
        case imageDataError
        case imageUrlError
        case deletionError
        case error(String)
    }
    
    ///Shared instance
    static var shared = StorageManager()
    
    private init() {}
    
    private var reference: StorageReference {
        Storage.storage().reference(withPath: FirebaseDatabasesPaths.reportVehicleImageStoragePath)
    }
    
    ///Deletes the vehicle image associated with the report.
    func deleteVehicleImage(path: String?) async throws {
        guard let path else { return }
        try await reference.child(path).delete()
    }
    
    ///Uploads the vehicles image to storage associated with the report UUID.
    func saveVehicleImage(_ image: UIImage?, reportType: ReportType, id: UUID) async throws -> String? {
        guard let image else { return nil }
        
        guard let imageData = image.pngData() else {
            throw StorageManagerError.imageDataError
        }
        
        let stroagePath = "\(reportType.rawValue)/\(id.uuidString)"
        
        let _ = try await reference.child(stroagePath).putDataAsync(imageData)
        
        guard let url = try? await reference.child(stroagePath).downloadURL() else {
            throw StorageManagerError.imageUrlError
        }
                
        return url.absoluteString
    }
}
