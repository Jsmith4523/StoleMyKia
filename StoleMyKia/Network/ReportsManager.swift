//
//  ReportAPI.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/16/23.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore
import CoreLocation

enum ReportManagerError: String, Error {
    case imageUrlError = "Image URL Error."
    case doesNotExist = "Report Does Not Exist."
    case dataError = "Data Error"
    case codableError = "Codable Protocol Error"
    case locationServicesDenied = "User Location Services Denied"
    case error = "Generic Error"
}

enum ReportNotation {
    case licensePlate(String)
    case vin(String)
    
    var notationValue: String {
        switch self {
        case .licensePlate(_):
            return "vehicle.licensePlate"
        case .vin(_):
            return "vehicle.vin"
        }
    }
}

///Manages uploading, retrieving, and delete reports.
class ReportManager {
    
    ///Shared instance.
    static let manager = ReportManager()
        
    private let db = Firestore.firestore()
    
    private var collection: CollectionReference {
        db.collection("Reports")
    }
    
    /// Retrieves the latest reports from Firestore Database.
    /// - Returns: An array of reports.
    /// - Throws: Error if the user location settings are not enabled or documents could not be retrieved.
    func fetch() async throws -> [Report] {
        let documents = try await self.collection.getDocuments()
        let reports = documents.reportsFromSnapshot()
        
        return reports
    }
    
    ///Retrieves a single report from Firestore Database.
    ///- Parameters:
    /// - id: The UUID value of a report.
    /// - Returns: Report that matches the UUID value.
    /// - Throws: Error if reports could not be retrieved or no longer exist.
    func fetchSingleReport(_ id: UUID, errorIfUnavaliable: Bool = true) async throws -> Report? {
        
        let document = try await collection.document(id.uuidString).getDocument()
                
        guard document.exists else {
            if errorIfUnavaliable {
                throw ReportManagerError.doesNotExist
            } else {
                return nil
            }
        }
        
        guard let data = document.data() else {
            throw ReportManagerError.dataError
        }
        
        guard let report = JSONSerialization.objectFromData(Report.self, jsonObject: data) else {
            throw ReportManagerError.codableError
        }
                        
        return report
    }
    
    /// Get any available updates for a original report
    /// - Parameter reportId: The UUID of the original report
    /// - Returns: An array of reports that are updates
    func fetchUpdates(_ reportId: UUID) async throws -> [Report] {
        let collection = collection.document(reportId.uuidString).collection("Updates")
        let documents = try await collection.getDocuments().documents
               
        let documentData = documents.map({$0.data()})
        let updates = documentData
            .map({JSONSerialization.objectFromData(Update.self, jsonObject: $0)})
            .compactMap({$0})
        
        let reportIds = updates.map({$0.reportId})
        
        var reports = [Report?]()
        for id in reportIds {
            let report = try await fetchSingleReport(id)
            reports.append(report)
        }
        
        return reports.compactMap({$0})
    }
    
    ///Retrieves reports from Firestore Database with a matching dot notation
    ///- Parameters:
    /// - notation: A notation type
    /// - Returns: Report(s) that matches notation.
    /// - Throws: Error if reports could not be retrieved.
    func fetchReportsWithNotation(_ notation: ReportNotation) async throws -> [Report] {
        //Retrieving documents that match the query...
        let documents = try await self.collection.getDocuments()
        
        return documents.reportsFromSnapshot()
    }
    
    func appendUpdateToReport(_ originalReportId: UUID, update: Update) async throws -> String {
        //Check if the original report still exist
        guard try await reportDoesExist(originalReportId) else {
            throw ReportManagerError.doesNotExist
        }
        
        guard let jsonData = try update.encodeForAppending() as? [String: Any] else {
            throw ReportManagerError.codableError
        }
        
        try await db.document("\(FirebaseDatabasesPaths.reportsDatabasePath)\(originalReportId.uuidString)")
            .collection("Updates")
            .document(update.id.uuidString)
            .setData(jsonData)
        
        //Returning the update UUID string...
        return update.id.uuidString
    }
    
    /// Uploads a report to Firestore Database. Also uploads the associated vehicle image (if included) to Firebase Storage.
    /// - Parameters:
    /// - report: The report object to be encoded and uploaded to Firestore.
    /// - image: The optional image of a vehicle associated with a report and uploaded to Firebase Storage. nill by default.
    /// - Throws: Error if either the report or its image could not be uploaded.
    func upload(_ report: Report, image: UIImage? = nil) async throws {
        var report = report
        
        //Saving the vehicle image to Firebase Storage...
        let imageUrl = try await StorageManager.shared.saveVehicleImage(image,
                                                                        reportType: report.reportType,
                                                                        id: report.id)
        //Retrieving the image url...
        report.imageURL = imageUrl
        
        //Then encoding the report...
        guard let jsonData = try report.encodeForUploading() as? [String: Any] else {
            throw ReportManagerError.codableError
        }
        
        //Now upload!
        try await collection.document(report.id.uuidString).setData(jsonData)
    }
    
    /// Deletes a report and associated vehicle image from Firestore Database and Firebase Storage.
    /// - Parameters:
    /// - id: The UUID value of a report.
    /// - path: The absolute file path of the vehicle image in Storage.
    /// - Throws: Error if either the report or it's vehicle image could not be deleted
    func delete(_ id: UUID, path: String) async throws {
        try await StorageManager.shared.deleteVehicleImage(path: path)
        
        try await self.collection.document(id.uuidString).delete()
    }
    
    /// Checks the Firestore collection if a report still exists in the database.
    /// - Parameter id: The UUID of the report.
    /// - Returns: True if the report exists and no errors are thrown.
    /// - Throws: Error if the report could not be retrieved.
    func reportDoesExist(_ id: UUID) async throws -> Bool {
        let document = try await collection
            .document(id.uuidString)
            .getDocument()
        
        guard document.exists else {
            return false
        }
        
        return true
    }
}

