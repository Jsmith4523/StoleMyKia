//
//  ReportAPI.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/16/23.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore

typealias ImageDataCompletion    = ((Result<UIImage, Error>)->Void)
typealias ReportsCompletion      = ((Result<[Report], Error>)->Void)
typealias DeleteReportCompletion = ((Result<Bool, Error>)->Void)
typealias UploadReportCompletion = ((Result<Bool, Error>)->Void)

typealias RemovalCompletion     = (UUID) -> ()

class ReportsManager {
    
    //TODO: Refactor code
    
    enum RMError: Error {
        case error(String)
    }
    
    private let storage = Storage.storage().reference()
    private let database = Firestore.firestore()
    
    private var collection: CollectionReference {
        database.collection("Reports")
    }
    
    private var storageReference: StorageReference {
        storage.storage.reference(withPath: "/vehicles")
    }
    
    func fetchReports(completion: @escaping ReportsCompletion) {
        collection.getDocuments { snapshot, err in
            guard let snapshot, err == nil else {
                completion(.failure(RMError.error(err?.localizedDescription ?? "Snapshot error recieving reports")))
                return
            }
            do {
                let reports = try snapshot.createReports()
                completion(.success(reports))
            } catch {
                completion(.failure(RMError.error("There was an error recieving documents")))
            }
        }
    }
    
    func fetchUserReports(uid: String?, completion: @escaping ((Result<[Report], Error>)->Void)) {
        guard let uid else {
            completion(.failure(RMError.error("user uid not provided")))
            return
        }
        collection.whereField("uid", isEqualTo: uid).getDocuments { snapshot, err in
            guard let snapshot, err == nil else {
                completion(.failure(RMError.error(err?.localizedDescription ?? "Snapshot error with user reports")))
                return
            }
            
            do {
                let reports = try snapshot.createReports()
                completion(.success(reports))
            } catch {
                completion(.failure(RMError.error(error.localizedDescription)))
            }
        }
    }
    
    func fetchUserBookmarkReports(_ uuids: [UUID], removalCompletion: @escaping RemovalCompletion, completion: @escaping (Result<[Report], Error>) -> Void) {
        var reports = [Report]()
        
        for documentID in uuids {
            self.collection.document(documentID.uuidString).getDocument { snapshot, err in
                guard let snapshot else {
                    completion(.failure(RMError.error(err?.localizedDescription ?? "There was an error getting user bookmarks")))
                    return
                }
                
                guard err == nil else {
                    completion(.failure(RMError.error(err?.localizedDescription ?? "There was an error getting user bookmarks")))
                    return
                }
                
                if !(snapshot.exists) {
                    removalCompletion(documentID)
                }
                
                guard let report = snapshot.createReport() else {
                    return
                }
                
                reports.append(report)
                completion(.success(reports))
            }
        }
    }
    
    func fetchUserUpdates(_ uuids: [UUID], completion: @escaping (Result<[Report], Error>) -> Void) {
        var reports = [Report?]()
                
        for documentID in uuids.map{$0.uuidString} {
            self.collection.document(documentID).getDocument { snapshot, err in
                print(snapshot?.exists)
                
                guard let snapshot, err == nil else {
                    completion(.failure(RMError.error(err?.localizedDescription ?? "There was an error getting user updates")))
                    return
                }
                reports.append(snapshot.createReport())
            }
        }
        
        completion(.success(reports.compactMap{$0}))
    }
    
    func uploadReport(report: Report, image: UIImage? = nil, completion: @escaping UploadReportCompletion) {
        do {
            var report = report
            
            guard let image else {
                try sendOffReport(report: report)
                return
            }
            
            uploadImage { result in
                switch result {
                case .success(let imageUrl):
                    report.imageURL = imageUrl
                    try? sendOffReport(report: report)
                case .failure(let reason):
                    completion(.failure(reason))
                    break
                }
            }
        } catch {
            completion(.failure(RMError.error("There was an error uploading the report")))
        }
        
        func uploadImage(imageCompletion: @escaping ((Result<String, Error>)->Void)) {
            guard let image, let imageData = image.pngData() else {
                completion(.failure(RMError.error("Method called but there was an error uploading image...")))
                return
            }
            
            storageReference.child(report.id.uuidString).putData(imageData) { [weak self] metadata, err in
                guard err == nil else {
                    imageCompletion(.failure(RMError.error("Failed to upload image to storage")))
                    return
                }
                
                self?.storageReference.child(report.id.uuidString).downloadURL { url, err in
                    guard let url, err == nil else {
                        imageCompletion(.failure(RMError.error("Image failed to download URL")))
                        return
                    }
                    imageCompletion(.success(url.absoluteString))
                }
            }
        }
        
        func sendOffReport(report: Report) throws {
            let ref = collection.document("\(report.id.uuidString)")
            
            let data = try JSONEncoder().encode(report)
            let jsonData = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            guard let jsonData else {
                throw RMError.error("JSON Data not available")
            }
            
            ref.setData(jsonData, merge: true) { err in
                if let err {
                    completion(.failure(RMError.error(err.localizedDescription)))
                    return
                }
                
                completion(.success(true))
            }
        }
    }
    
    func delete(report: Report, completion: @escaping DeleteReportCompletion) {
        let ref = collection.document("\(report.id.uuidString)")
        
        guard !(report.imageURL == nil) else {
            deleteReport { err in
                guard err == nil else {
                    completion(.failure(err!))
                    return
                }
                completion(.success(true))
            }
            return
        }
        
        deleteImage(id: report.id.uuidString) { err in
            guard err == nil else {
                completion(.failure(err!))
                return
            }
            deleteReport { err in
                guard err == nil else {
                    completion(.failure(err!))
                    return
                }
                completion(.success(true))
            }
        }
        
        func deleteImage(id: String, completion: @escaping ((Error?)->Void)) {
            self.storageReference.child(id).delete { err in
                guard err == nil else {
                    completion(RMError.error("Unable to delete image from storage"))
                    return
                }
                completion(nil)
            }
        }
        
        func deleteReport(completion: @escaping ((Error?)->Void)) {
            ref.delete { err in
                if let err {
                    completion(RMError.error(err.localizedDescription))
                    return
                }
                
                completion(nil)
            }
        }
    }
    
    func createObserver(completion: @escaping (()->Void)) {
        database.collection("Reports").addSnapshotListener { snapshot, err in
            snapshot?.documentChanges.forEach { docChange in
                if docChange.type == .removed {
                    completion()
                }
            }
        }
    }
    
    func deleteUserReports(uid: String?, completion: @escaping ((Bool)->Void)) {
        guard let uid else {
            completion(false)
            return
        }
        
        collection.whereField("uid", isEqualTo: uid).getDocuments { [weak self] snapshot, err in
            guard let snapshot, err == nil else {
                completion(false)
                return
            }
            
            do {
                let userReports = try snapshot.createReports()
                userReports.forEach { report in
                    self?.delete(report: report) { status in
                        switch status {
                        case .success(_):
                            break
                        case .failure(_):
                            completion(false)
                        }
                    }
                }
                completion(true)
            } catch {
                completion(false)
            }
        }
    }
}

private extension QuerySnapshot {
    
    func createReports() throws -> [Report] {
        var reports = [Report]()
        
        for document in self.documents {
            let documentData = try JSONSerialization.data(withJSONObject: document.data())
            var report = try JSONDecoder().decode(Report.self, from: documentData)
            report.id = UUID(uuidString: report.id.uuidString)!
            reports.append(report)
        }
        
        return reports
    }
}

private extension DocumentSnapshot {
    
    func createReport() -> Report? {
        guard let data = self.data() else {
            return nil
        }
        
        do {
            let serializedData = try JSONSerialization.data(withJSONObject: data)
            let report = try JSONDecoder().decode(Report.self, from: serializedData)
            
            return report
        } catch {
            return nil
        }
        
        return nil
    }
}
