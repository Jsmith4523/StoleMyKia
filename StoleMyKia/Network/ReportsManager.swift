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
    
    private let database = Firestore.firestore()
    
    private var collection: CollectionReference {
        database.collection("Reports")
    }
    
    ///Fetches reports in the database
    func fetchReports(completion: @escaping ReportsCompletion) {
        collection.getAllDocuments { result in
            switch result {
            case .success(let reports):
                completion(.success(reports))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    ///Fetches reports matching the uid.
    func fetchUserReports(uid: String?, completion: @escaping ReportsCompletion) {
        guard let uid else {
            completion(.failure(RMError.error("user uid not provided")))
            return
        }
        collection.whereField("uid", isEqualTo: uid).getQueryDocuments { result in
            switch result {
            case .success(let reports):
                completion(.success(reports))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    ///Fetches the current logged in user bookmarked reports.
    func fetchUserBookmarkReports(_ uuids: [UUID], removalCompletion: @escaping RemovalCompletion, completion: @escaping (Result<[Report], Error>) -> Void) {
        
        var reports = [Report?]()
        
        for documentID in uuids {
            self.collection.document(documentID.uuidString).getDocumentMatchingReference(Report.self) { result in
                switch result {
                case .success(let report):
                    reports.append(report)
                    completion(.success(reports.compactMap{$0}))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    ///Fetches the current logged in users updates.
    func fetchUserUpdates(_ uuids: [UUID], completion: @escaping (Result<[Report], Error>) -> Void) {
        var reports = [Report?]()
        
        for documentID in uuids.map({$0.uuidString}) {
            //TODO: Condition base on report type
            self.collection.document(documentID).getDocumentMatchingReference(Report.self) { result in
                switch result {
                case .success(let report):
                    reports.append(report)
                    completion(.success(reports.compactMap{$0}))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func reportDoesExist(uuid: UUID, completion: @escaping (Bool) -> Void) {
        self.collection.document(uuid.uuidString).doesExist { result in
            completion(result)
        }
    }
    
    func uploadReport(report: Report, image: UIImage? = nil, completion: @escaping UploadReportCompletion) {
        collection.uploadReport(report, with: image) { result in
            switch result {
            case .success(_):
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func delete(report: Report, completion: @escaping DeleteReportCompletion) {
        collection.document(report.id.uuidString).beginDelection { result in
            switch result {
            case .success(let success):
                completion(.success(success))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func deleteUserReports(uid: String?, completion: @escaping ((Bool)->Void)) {
        guard let uid else {
            completion(false)
            return
        }
        
        collection.whereField("uid", isEqualTo: uid).deleteAll { result in
            switch result {
            case .success(_):
                completion(true)
            case .failure(let error):
                completion(false)
                print(error.localizedDescription)
            }
        }
    }
}

