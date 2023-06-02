//
//  QuerySnapshot.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/2/23.
//

import Foundation
import FirebaseDatabase
import Firebase

/*
    Contains methods to retrieving and uploading data from firestore
 */

public enum RMError: Error {
    case decodingError
    case encodingError
    case deletionError
    case documentError
    case uploadImageError
    case uploadError
    case snapshotError(String)
    case error(String)
}

extension QuerySnapshot {
    
    
    ///Creates multiple objects
    private func createObjects<T: Codable>(_ type: [T.Type]) throws -> [T] {
        return try JSONSerialization.objectsFromSnapshot(self.documents, to: type)
    }
    
    func getDocuments<T: Codable>(_ type: [T.Type], completion: @escaping (Result<[T], RMError>) -> Void) {
        do {
            let documents = try self.createObjects(type)
            completion(.success(documents))
        } catch {
            completion(.failure(.snapshotError(error.localizedDescription)))
        }
    }
}

extension DocumentSnapshot {
    
    ///Creates a single object
    func createFromObject<T: Codable>(_ type: T.Type) throws -> T? {
        return try JSONSerialization.createObjectWithData(T.self, jsonObject: self.data())
    }
    
    func getSingleDocument<T: Codable>(_ type: T.Type, completion: @escaping (T?) -> Void) {
        do {
            completion(try self.createFromObject(type))
        } catch {
            completion(nil)
        }
    }
}

extension [QueryDocumentSnapshot] {
    
    func deleteAll(completion: @escaping (Result<Bool, Error>) -> Void) {
        for document in self {
            document.reference.beginDelection { result in
                switch result {
                case .success(_):
                    break
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        completion(.success(true))
    }
}

extension DocumentReference {
    
    func getDocumentMatchingReference<T: Codable>(_ type: T.Type, errorIfNotFound: Bool = false, completion: @escaping (Result<T?, RMError>) -> Void) {
        self.getDocument { snapshot, err in
            guard let snapshot, err == nil else {
                completion(.failure(.error(err?.localizedDescription ?? "There was an error")))
                return
            }
            
            guard snapshot.exists, !(errorIfNotFound) else {
                completion(.failure(.snapshotError("Snapshot no longer exist")))
                return
            }
            
            snapshot.getSingleDocument(type) { document in
                completion(.success(document))
            }
        }
    }
    
    func doesExist(completion: @escaping (Bool) -> Void) {
        self.getDocument { snapshot, err in
            guard let snapshot, err == nil, snapshot.exists else {
                completion(false)
                return
            }
            
            completion(true)
        }
    }
    
    private func deleteReference(completion: @escaping (Result<Bool, Error>) -> Void) {
        self.delete { err in
            guard err  == nil else {
                completion(.failure(RMError.deletionError))
                return
            }
            completion(.success(true))
        }
    }
    
    func beginDelection(completion: @escaping (Result<Bool, Error>) -> Void) {
        self.getDocumentMatchingReference(Report.self) { result in
            switch result {
            case .success(let report):
                delete(report?.imageURL)
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        
        func delete(_ imageURL: String?) {
            Storage.deleteVehicleImage(imageURL) { [weak self] result in
                switch result {
                case .success(_):
                    self?.deleteReference { status in
                        switch status {
                        case .success(_):
                            completion(.success(true))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}

extension CollectionReference {
    
    func getAllDocuments<T: Codable>(_ type: [T.Type] = [Report.self], completion: @escaping (Result<[T], RMError>) -> Void) {
        self.getDocuments { snapshot, err in
            guard let snapshot, err == nil else {
                completion(.failure(.snapshotError(err?.localizedDescription ?? "There was an error")))
                return
            }
            
            snapshot.getDocuments(type) { result in
                switch result {
                case .success(let documents):
                    completion(.success(documents))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    ///Uploads a report and vehicle Image (if included) to Firestore and Storage
    func uploadReport(_ report: Report, with image: UIImage?, completion: @escaping (Result<Bool, RMError>)->Void) {
        var report = report
        
        Storage.setVehicleImage(to: report.id, image) { result in
            switch result {
            case .success(let imageUrl):
                report.imageURL = imageUrl
                upload()
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        func upload() {
            do {
                guard let data = try report.encodeForUploading() as? [String: Any] else {
                    completion(.failure(.encodingError))
                    return
                }
                
                self.addDocument(data: data) { err in
                    guard err == nil else {
                        completion(.failure(.uploadError))
                        return
                    }
                    completion(.success(true))
                }
            } catch {
                completion(.failure(.encodingError))
            }
        }
    }
}

extension Query {
    
    func getQueryDocuments<T: Codable>(_ type: [T.Type] = [Report.self], completion: @escaping (Result<[T], RMError>) -> Void) {
        self.getDocuments { snapshot, err in
            guard let snapshot, err == nil else {
                completion(.failure(.snapshotError(err?.localizedDescription ?? "There was an error")))
                return
            }
            
            snapshot.getDocuments(type) { result in
                switch result {
                case .success(let documents):
                    completion(.success(documents))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    ///WARNING: Only use for user reports
    func deleteAll(completion: @escaping (Result<Bool, Error>) -> Void) {
        self.getDocuments { snapshot, err in
            guard let snapshot else {
                completion(.failure(RMError.snapshotError("")))
                return
            }
            
            snapshot.documents.deleteAll { result in
                switch result {
                case .success(_):
                    completion(.success(true))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}


