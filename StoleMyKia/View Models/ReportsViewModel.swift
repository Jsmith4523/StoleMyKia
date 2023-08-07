//
//  ReportsViewModel.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/11/23.
//

import Foundation
import SwiftUI
import UIKit
import MapKit

final class ReportsViewModel: NSObject, ObservableObject {
        
    @Published var isFetchingReports = false
    @Published var isShowingLicensePlateScannerView = false

    @Published var feedLoadStatus: FeedLoadStatus = .loading
    @Published var reports: [Report] = []
    
    private let manager = ReportManager()

    weak private var delegate: ReportsDelegate?
    weak private var firebaseUserDelegate: FirebaseUserDelegate?
    
    override init() {
        print("Alive: ReportsViewModel")
        super.init()
    }
    
    func setFirebaseUserDelegate(_ delegate: FirebaseUserDelegate) {
        self.firebaseUserDelegate = delegate
    }
    
    @MainActor
    func fetchReports() async {
        do {
            let fetchedReports = try await manager.fetch()
            self.reports = fetchedReports
            self.feedLoadStatus = .loaded
        } catch {
            self.feedLoadStatus = .loaded
        }
    }
    
    /// Asynchronously upload a report and its vehicle image to Google Firestore and Firebase Storage
    /// - Parameters:
    ///   - report: The report object to be encoded and uploaded.
    ///   - image: The optional image to be unwrapped and uploaded
    func uploadReport(_ report: Report, image: UIImage? = nil) async throws {
        try await manager.upload(report, image: image)
        await UINotificationFeedbackGenerator().notificationOccurred(.success)
        await fetchReports()
    }
    
    func deleteReport(report: Report) async throws {
        try await manager.delete(report.id, path: report.vehicleImagePath)
    }
    
    /// Update a original report
    /// - Parameters:
    ///   - originalReportId: The UUID of the original report
    ///   - update: The Update object
    func addUpdateToOriginalReport(originalReport: Report, report: Report, vehicleImage: UIImage? = nil) async throws {
        guard let uid = firebaseUserDelegate?.uid else {
            throw ReportManagerError.error
        }
        
        guard try await manager.reportDoesExist(originalReport.id) else {
            throw ReportManagerError.doesNotExist
        }
        
        var report = report
        let update = Update(uid: uid, authorUid: originalReport.uid, type: report.reportType, vehicle: report.vehicle, reportId: report.id, dt: report.dt)
        let updateId = try await manager.appendUpdateToReport(originalReport.role.associatedValue, update: update)
        
        report.updateId = updateId
        
        try await uploadReport(report, image: vehicleImage)
    }
    
    deinit {
        print("Dead: ReportsViewModel")
    }
}

//MARK: - TimelineMapViewDelegate
extension ReportsViewModel: TimelineMapViewDelegate {
    func getTimelineUpdates(for report: Report) async throws -> [Report] {
        //Using the associated value for both original and update reports
        try await manager.fetchUpdates(report.role.associatedValue)
    }
}


//MARK: - LicensePlateCoordinatorDelegate
extension ReportsViewModel: LicensePlateCoordinatorDelegate {
    func fetchReportsWithLicense(_ licenseString: String) async throws -> [Report] {
        return [Report]()
    }
}
