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

enum ReportManagerError: Error {
    case imageUrlError
    case doesNotExist
    case dataError
    case codableError
    case locationServicesDenied
    case error(String)
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

class ReportManager {
    
    ///Shared instance.
    static let manager = ReportManager()
        
    private static let db = Firestore.firestore()
    
    private static var collection: CollectionReference {
        db.collection("Reports")
    }
    
    private init() {}
    
    /// Retrieves the latest reports from Firestore Database.
    ///
    /// - Returns: An array of reports.
    ///
    /// - Throws: Error if the user location settings are not enabled or documents could not be retrieved.
    func fetch() async throws -> [Report] {
        guard CLLocationManager.shared.authorizationStatus.isAuthorized else {
            throw ReportManagerError.locationServicesDenied
        }
                
        let documents = try await Self.collection.getDocuments()
        let reports = documents.reportsFromSnapshot()
        
        return reports
    }
    
    ///Retrieves a single report from Firestore Database.
    ///
    ///- Parameters:
    /// - id: The UUID value of a report.
    ///
    /// - Returns: Report that matches the UUID value.
    ///
    /// - Throws: Error if reports could not be retrieved or no longer exist.
    static func fetchSingleReport(_ id: UUID) async throws -> Report {
        
        let document = try await collection.document(id.uuidString).getDocument()
        
        guard document.exists else {
            throw ReportManagerError.doesNotExist
        }
        
        guard let data = document.data() else {
            throw ReportManagerError.dataError
        }
        
        guard let report = JSONSerialization.objectFromData(Report.self, jsonObject: data ) else {
            throw ReportManagerError.codableError
        }
        
        return report
    }
    
    ///Retrieves reports from Firestore Database with a matching dot notation
    ///
    ///- Parameters:
    /// - notation: A notation type
    ///
    /// - Returns: Report(s) that matches notation.
    ///
    /// - Throws: Error if reports could not be retrieved.
    func fetchReportsWithNotation(_ notation: ReportNotation) async throws -> [Report] {
        //Retrieving documents that match the query...
        let documents = try await Self.collection.getDocuments()
        
        return documents.reportsFromSnapshot()
    }
    
    /// Uploads a report to Firestore Database. Also uploads the associated vehicle image (if included) to Firebase Storage.
    ///
    /// - Parameters:
    ///   - report: The report object to be encoded and uploaded to Firestore.
    ///
    ///   - image: The optional image of a vehicle associated with a report and uploaded to Firebase Storage. nill by default.
    ///
    ///   - Throws: Error if either the report or its image could not be uploaded.
    func upload(_ report: Report, image: UIImage? = nil) async throws {
        var report = report
        
        //Saving the vehicle image to Firebase Storage...
        let imageUrl = try await StorageManager.shared.saveVehicleImage(image, to: report.vehicleImagePath)
        //Retrieving the image url...
        report.imageURL = imageUrl?.absoluteString ?? nil
        
        //Then encoding the report...
        guard let jsonData = try JSONSerialization.createJsonFromObject(report) as? [String: Any] else {
            throw ReportManagerError.codableError
        }
        
        //Now upload!
        try await Self.collection.document(report.id.uuidString).setData(jsonData)
    }
    
    
    /// Deletes a report and associated vehicle image from Firestore Database and Firebase Storage.
    /// - Parameters:
    ///   - id: The UUID value of a report.
    ///
    ///   - path: The absolute file path of the vehicle image in Storage.
    ///
    ///   - Throws: Error if either the report or it's vehicle image could not be deleted
    func delete(_ id: UUID, path: String) async throws {
        try await StorageManager.shared.deleteVehicleImage(path: path)
        
        try await Self.collection.document(id.uuidString).delete()
    }
}

