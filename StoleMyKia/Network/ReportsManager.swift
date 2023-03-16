//
//  ReportAPI.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/16/23.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore

typealias ImageDataCompletion = ((Result<UIImage, Error>)->Void)
typealias ReportsCompletion   = ((Result<[Report], Error>)->Void)

class ReportsManager {
    
    enum ReportManagerError: Error {
        case error(String)
    }
    
    private let storage = Storage.storage()
    private let database = Firestore.firestore()

    func fetchPostImage(from url: URL?, completion: @escaping ImageDataCompletion) {
        guard let url else{
            completion(.failure(ReportManagerError.error("Image url invalid")))
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, err in
            guard let data, err == nil else {
                completion(.failure(ReportManagerError.error("Failed to download image")))
                return
            }
            
            if let image = UIImage(data: data) {
                completion(.success(image))
            }
        }
        task.resume()
    }
    
    func fetchReports(completion: @escaping ReportsCompletion) {
        let collection = database.collection("Reports")
        collection.getDocuments { snapshot, err in
            if let err {
                completion(.failure(ReportManagerError.error(err.localizedDescription)))
                return
            }
            if let snapshot, err == nil {
                snapshot.documents.compactMap { snapshot in
                    
                }
            }
        }
    }
}
