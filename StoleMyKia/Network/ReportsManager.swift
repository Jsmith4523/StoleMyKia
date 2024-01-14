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
    case doesNotExist = "The initial report no longer exists"
    case dataError = "Data Error"
    case codableError = "Codable Protocol Error"
    case updatesDisable = "Updates Disabled for this report."
    case locationServicesDenied = "User Location Services Denied"
    case desiredLocationNotSet
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
public class ReportManager {
    
    ///Shared instance.
    static let manager = ReportManager()
        
    private let db = Firestore.firestore()
    
    private init() {}
    
    private var collection: CollectionReference {
        db.collection("Reports")
    }
    
    /// Retrieves the latest reports from Firestore Database that are within the users desired location.
    /// - Returns: An array of reports ascending within the desired location or latest.
    /// - Throws: Error if the user location settings are not enabled or documents could not be retrieved.
    func fetch() async throws -> [Report] {
        let desiredLocation = await FirebaseUserManager.shared.getUserLocationConfiguration()
        
        let reports = try await fetchReports()
        
        guard let desiredLocation else {
            throw ReportManagerError.desiredLocationNotSet
        }
        
        return reports.filterBasedUponLocation(desiredLocation.coordinate, radius: desiredLocation.radius).sorted(by: >)
    }
    
    ///Fetch reports from Firestore.
    func fetchReports() async throws -> [Report] {
        let documents = try await self
            .collection
            .getDocuments()
        let reports = documents.reportsFromSnapshot()
        return reports
    }
    
    /// Fetch reports filtered and based upon the users current location
    /// - Returns: An array of reports ascending by closest to current user
    func fetchLocalReports() async throws -> [Report] {
        let userLocation = CLLocationManager.shared.usersCurrentLocation
        
        let reports = try await fetchReports()
        
        if let userLocation {
            //7 miles from user's location
            return reports.filterBasedUponLocation(userLocation, radius: 11265).sorted(by: >)
        } else {
            throw ReportManagerError.locationServicesDenied
        }
    }
    
    ///Retrieves a single report from Firestore Database.
    ///- Parameters:
    /// - id: The UUID value of a report.
    /// - Returns: Report that matches the UUID value.
    /// - Throws: Error if reports could not be retrieved or no longer exist.
    func fetchSingleReport(_ id: UUID, errorIfUnavaliable: Bool = true) async throws -> Report? {
        let document = try await collection
            .document(id.uuidString)
            .getDocument()
                
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
        let collection = collection
            .document(reportId.uuidString)
            .collection(FirebaseDatabasesPaths.reportUpdatesPath)
        
        let documents = try await collection.getDocuments().documents
               
        let documentData = documents.map({$0.data()})
        let updates = documentData
            .map({JSONSerialization.objectFromData(Update.self, jsonObject: $0)})
            .compactMap({$0})
        
        let reportIds = updates.map({$0.reportId})
        
        var reports = [Report?]()
        for id in reportIds {
            //Make sure the bool value is set to false in case firebase cannot retrieve the report.
            let report = try await fetchSingleReport(id, errorIfUnavaliable: false)
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
        try await FirebaseAuthManager.manager.userCanPerformAction()
        
        //Check if the original report still exist
        guard try await reportDoesExist(originalReportId) else {
            throw ReportManagerError.doesNotExist
        }
        
        guard let jsonData = try update.encodeForAppending() as? [String: Any] else {
            throw ReportManagerError.codableError
        }
        
        try await db
            .document("\(FirebaseDatabasesPaths.reportsDatabasePath)\(originalReportId.uuidString)")
            .collection(FirebaseDatabasesPaths.reportUpdatesPath)
            .document(update.id.uuidString)
            .setData(jsonData)
        
        //Returning the update UUID string...
        return update.id.uuidString
    }
    
    /// Uploads a report to Firestore Database. Also uploads the associated vehicle image (if included) to Firebase Storage.
    /// - Parameters:
    /// - report: The report object to be encoded and uploaded to Firestore.
    /// - image: The optional image of a vehicle associated with a report and uploaded to Firebase Storage. nill by default.
    /// - Returns: The image url of the report if possibe.
    func upload(_ report: Report, image: UIImage? = nil) async throws {
        var report = report
        
        try await FirebaseAuthManager.manager.userCanPerformAction()
        
        if let image {
            //Saving the vehicle image to Firebase Storage...
            let imageUrl = try await StorageManager.shared.saveVehicleImage(image,
                                                                            reportType: report.reportType,
                                                                            id: report.id)
            //Retrieving the image url...
            report.imageURL = imageUrl
        }
        
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
    /// - ImageId: The Image ID in Storage.
    /// - Throws: Error if either the report or it's vehicle image could not be deleted
    func delete(_ report: Report) async throws {
        try await StorageManager.shared.deleteVehicleImage(path: report.vehicleImagePath)
        try await self.collection
            .document(report.id.uuidString)
            .delete()
        
        ImageCache.shared.removeFromCache(report.imageURL)
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
    
    
    /// Determines if an initial
    /// - Parameter id: The id of the report
    func allowsForUpdates(id: UUID) async throws  {
        guard let initialReport = try await fetchSingleReport(id) else {
            throw ReportManagerError.error
        }
        
        guard (initialReport.allowsForUpdates && !initialReport.hasBeenResolved) else {
            throw ReportManagerError.updatesDisable
        }
    }
    
    /// Retrieves the current number of updates a report has
    /// - Parameter report: The report to check for number of updates based upon it's role associated UUID value.
    /// - Returns: The int quantity of updates
    func getNumberOfUpdates(_ report: Report) async -> Int {
        do {
            let count = try await collection.document(report.role.associatedValue.uuidString)
                .collection(FirebaseDatabasesPaths.reportUpdatesPath)
                .getDocuments()
                .count
            return count
        } catch {
            return 0
        }
    }
    
    /// Disables updates for a report
    /// - Parameter id: The UUID of the report to disable updates for.
    func disableUpdates(_ id: UUID) async throws {
        try await FirebaseAuthManager.manager.userCanPerformAction()
        
        guard try await self.reportDoesExist(id) else {
            throw ReportManagerError.doesNotExist
        }
        
        try await Firestore.firestore()
            .collection(FirebaseDatabasesPaths.reportsDatabasePath)
            .document(id.uuidString)
            .updateData(["allowsForUpdates": false])
    }
    
    /// Disables contacting for a report
    /// - Parameter id: The UUID of the report to disable contacting for.
    func disableContacting(_ id: UUID) async throws {
        guard try await self.reportDoesExist(id) else {
            throw ReportManagerError.doesNotExist
        }
        
        try await Firestore.firestore()
            .collection(FirebaseDatabasesPaths.reportsDatabasePath)
            .document(id.uuidString)
            .updateData(["allowsForContact": false])
    }
    
    
    /// Updates a report document in firebase as resolved.
    /// - Parameter id: The UUID of the report to set as resolved.
    func setAsResolved(_ id: UUID) async throws {
        try await FirebaseAuthManager.manager.userCanPerformAction()
        
        guard try await self.reportDoesExist(id) else {
            throw ReportManagerError.doesNotExist
        }
        
        try await Firestore.firestore()
            .collection(FirebaseDatabasesPaths.reportsDatabasePath)
            .document(id.uuidString)
            .updateData(["allowsForUpdates": false])
        
        try await Firestore.firestore()
            .collection(FirebaseDatabasesPaths.reportsDatabasePath)
            .document(id.uuidString)
            .updateData(["hasBeenResolved": true])
    }
}

