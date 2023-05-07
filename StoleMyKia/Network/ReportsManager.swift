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

class ReportsManager {
    
    enum ReportManagerError: Error {
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
                completion(.failure(ReportManagerError.error("❌ Error retrieving reports: \(err?.localizedDescription ?? "There was an eror")")))
                return
            }
            do {
                let reports = try snapshot.createReports()
                completion(.success(reports))
            } catch {
                completion(.failure(ReportManagerError.error("There was an error recieving documents")))
            }
        }
    }
    
    func fetchUserReports(uid: String?, completion: @escaping ((Result<[Report], Error>)->Void)) {
        guard let uid else {
            completion(.failure(ReportManagerError.error("❌ Error retrieving user reports: uid is nil")))
            return
        }
        collection.whereField("uid", isEqualTo: uid).getDocuments { snapshot, err in
            guard let snapshot, err == nil else {
                completion(.failure(ReportManagerError.error("❌Error retrieving user reports: \(err?.localizedDescription ?? "There was an error")")))
                return
            }
            
            do {
                let reports = try snapshot.createReports()
                completion(.success(reports))
            } catch {
                completion(.failure(ReportManagerError.error("❌Error retrieving user reports: \(err?.localizedDescription ?? "There was an error")")))
            }
        }
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
            completion(.failure(ReportManagerError.error("There was an error uploading the report")))
        }
        
        func uploadImage(imageCompletion: @escaping ((Result<String, Error>)->Void)) {
            guard let image, let imageData = image.pngData() else {
                completion(.failure(ReportManagerError.error("Method called but there was an error uploading image...")))
                return
            }
            
            storageReference.child(report.id.uuidString).putData(imageData) { metadata, err in
                guard err == nil else {
                    imageCompletion(.failure(ReportManagerError.error("Failed to upload image to storage")))
                    return
                }
                self.storageReference.child(report.id.uuidString).downloadURL { url, err in
                    guard let url, err == nil else {
                        imageCompletion(.failure(ReportManagerError.error("Image failed to download URL")))
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
                throw ReportManagerError.error("JSON Data not available")
            }
            
            ref.setData(jsonData, merge: true) { err in
                if let err {
                    completion(.failure(ReportManagerError.error(err.localizedDescription)))
                    return
                }
                
                completion(.success(true))
            }
        }
    }
    
    func delete(report: Report, completion: @escaping DeleteReportCompletion) {
        let ref = collection.document("\(report.id.uuidString)")
        
        guard let imageUrl = report.imageURL else {
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
            storageReference.child(id).delete { err in
                guard err == nil else {
                    completion(ReportManagerError.error("Unable to delete image from storage"))
                    return
                }
                completion(nil)
            }
        }
        
        func deleteReport(completion: @escaping ((Error?)->Void)) {
            ref.delete { err in
                if let err {
                    completion(ReportManagerError.error(err.localizedDescription))
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
        
        collection.whereField("uid", isEqualTo: uid).getDocuments { snapshot, err in
            guard let snapshot, err == nil else {
                completion(false)
                return
            }
            
            guard !snapshot.documents.isEmpty else{
                completion(true)
                return
            }
            
            do {
                let userReports = try snapshot.createReports()
                
                for report in userReports {
                    self.delete(report: report) { status in
                        switch status {
                        case .success(_):
                            break
                        case .failure(_):
                            completion(false)
                        }
                    }
                }
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
