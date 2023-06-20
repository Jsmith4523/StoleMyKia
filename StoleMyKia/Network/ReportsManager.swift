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
    
    init() {
        self.uploadReport(report: .init(dt: Date.now.epoch, reportType: .stolen, vehicle: .init(vehicleYear: 2017, vehicleMake: .hyundai, vehicleColor: .black, vehicleModel: .elantra, licensePlate: try? EncryptedData.createEncryption(input: "1EP1757")), distinguishable: "", location: .init(lat: 43.2343, lon: -54.3242), role: .original)) { _ in
            
        }
    }
    
    ///Fetches reports in the database
    func fetchReports(completion: @escaping ReportsCompletion) {
        database.collection("Reports/").getAllDocuments { result in
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
//        database.collection("Reports/").whereField("uid", isEqualTo: uid).getQueryDocuments { result in
//            switch result {
//            case .success(let reports):
//                completion(.success(reports))
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
    }
    
    ///Fetches the current logged in user bookmarked reports.
    func fetchUserBookmarkReports(_ uuids: [UUID], removalCompletion: @escaping RemovalCompletion, completion: @escaping (Result<[Report], Error>) -> Void) {

        var reports = [Report?]()

        for documentID in uuids {
//            database.collection("Reports/").document(documentID.uuidString).getDocumentMatchingReference(Report.self) { result in
//                switch result {
//                case .success(let report):
//                    reports.append(report)
//                    completion(.success(reports.compactMap{$0}))
//                case .failure(let error):
//                    completion(.failure(error))
//                }
//            }
        }
    }
    
    ///Fetches the current logged in users updates.
    func fetchUserUpdates(_ uuids: [UUID], completion: @escaping (Result<[Report], Error>) -> Void) {
        var reports = [Report?]()

        for documentID in uuids.map({$0.uuidString}) {
            //TODO: Condition base on report type
//            database.collection("Reports/").document(documentID).getDocumentMatchingReference(Report.self) { result in
//                switch result {
//                case .success(let report):
//                    reports.append(report)
//                    completion(.success(reports.compactMap{$0}))
//                case .failure(let error):
//                    completion(.failure(error))
//                }
//            }
        }
    }
    
    func reportDoesExist(uuid: UUID, completion: @escaping (Bool) -> Void) {
//        database.collection("Reports/").document(uuid.uuidString).doesExist { result in
//            completion(result)
//        }
    }
    
    func uploadReport(report: Report, image: UIImage? = nil, completion: @escaping UploadReportCompletion) {
        database.collection("Reports/").uploadReport(report, with: image) { result in
            switch result {
            case .success(_):
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func delete(report: Report, completion: @escaping DeleteReportCompletion) {
//        database.collection("Reports/").document("\(report.id)").beginDelection { result in
//            switch result {
//            case .success(let success):
//                completion(.success(success))
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
    }
    
    ///Fetch single report by uuid
    func fetchReport(_ uuid: UUID, completion: @escaping (Result<Report, FetchReportError>) -> Void) {
        database.collection("Reports/").whereField("id", isEqualTo: uuid.uuidString).getDocuments { snapshot, err in
            guard let snapshot, err == nil else {
                print(err?.localizedDescription)
                completion(.failure(.unavaliable))
                return
            }

            guard let document = snapshot.documents.first else {
                completion(.failure(.deleted))
                return
            }

            guard document.exists else {
                completion(.failure(.deleted))
                return
            }

            guard let report = try? JSONSerialization.createObjectWithData(Report.self, jsonObject: document.data()) else {
                completion(.failure(.unavaliable))
                return
            }
            completion(.success(report))
        }
    }
    
    func deleteUserReports(uid: String?, completion: @escaping ((Bool)->Void)) {
        guard let uid else {
            completion(false)
            return
        }
        
//        database.collection("Reports/").whereField("uid", isEqualTo: uid).deleteAll { result in
//            switch result {
//            case .success(_):
//                completion(true)
//            case .failure(let error):
//                completion(false)
//                print(error.localizedDescription)
//            }
//        }
    }
}

