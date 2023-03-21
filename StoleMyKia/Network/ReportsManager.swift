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
typealias UploadReportCompletion = ((Result<Bool, Error>)->Void)

class ReportsManager {
    
    enum ReportManagerError: Error {
        case error(String)
    }
    
    private let storage = Storage.storage()
    private let database = Firestore.firestore()
    
    private var collection: CollectionReference {
        database.collection("Reports")
    }
    
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
        var reports = [Report]()
        
        collection.getDocuments { snapshot, err in
            if let err {
                completion(.failure(ReportManagerError.error(err.localizedDescription)))
                return
            }
            if let snapshot {
                do {
                    reports = try self.createReportFromDocuments(documents: snapshot.documents)
                } catch {
                    completion(.failure(ReportManagerError.error("There was an error recieving documents")))
                }
            }
            completion(.success(reports))
        }
    }
    
    func uploadReport(report: Report, completion: @escaping UploadReportCompletion) {
        do {
            let ref = collection.document("\(report.id.uuidString)")
            
            let data = try JSONEncoder().encode(report)
            let jsonData = try JSONSerialization.jsonObject(with: data) as? [String: Any]
           
            if let encodedData = jsonData {
                ref.setData(encodedData, merge: true) { err in
                    if let err {
                        completion(.failure(ReportManagerError.error(err.localizedDescription)))
                        return
                    }
                }
            }
        } catch {
            completion(.failure(ReportManagerError.error("There was an error uploading the report")))
        }
    }
    
    func createObserver() {
        database.collection("Reports").addSnapshotListener { snapshot, err in
            snapshot?.documentChanges.forEach { docChange in
                if docChange.type == .added {
                    print("Document added")
                }
            }
        }
    }
    
    private func createReportFromDocuments(documents: [QueryDocumentSnapshot]) throws -> [Report] {
        var reports = [Report]()
        
        for document in documents {
            let documentData = try JSONSerialization.data(withJSONObject: document.data())
            let report = try JSONDecoder().decode(Report.self, from: documentData)
            reports.append(report)
        }
        
        return reports
    }
}
