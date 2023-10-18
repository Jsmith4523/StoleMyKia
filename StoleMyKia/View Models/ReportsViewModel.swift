//
//  ReportsViewModel.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/11/23.
//

import Foundation
import SwiftUI
import FirebaseAuth
import UIKit
import MapKit

enum InfiniteScrollStatus {
    case idle, loading, error
    
    var title: String {
        switch self {
        case .idle:
            return "More"
        case .loading:
            return "Loading..."
        case .error:
            return "Failed To Reload"
        }
    }
}

@MainActor
final class ReportsViewModel: NSObject, ObservableObject {
        
    @Published var isFetchingReports = false
    @Published var isShowingLicensePlateScannerView = false

    @Published private(set) var infiniteScrollStatus: InfiniteScrollStatus = .idle
    @Published var feedLoadStatus: FeedLoadStatus = .loading
    @Published var reports: [Report] = []
    
    override init() {
        print("Alive: ReportsViewModel")
        super.init()
    }
    
    func fetchReports(showProgressView: Bool = false) async {
        if showProgressView {
            self.feedLoadStatus = .loading
        }
        
        do {
            let fetchedReports = try await ReportManager.manager.fetch()
            self.reports = fetchedReports
            guard !(reports.isEmpty) else {
                self.feedLoadStatus = .empty
                return
            }
            self.feedLoadStatus = .loaded
        } catch {
            self.feedLoadStatus = .error
        }
    }
    
    func fetchMoreReports(_ report: Report) async {
//        self.infiniteScrollStatus = .loading
//        do {
//            let reports = try await ReportManager.manager.fetchMoreAfterReport(report)
//            self.reports.append(contentsOf: reports)
//            self.infiniteScrollStatus = .idle
//        } catch {
//            self.infiniteScrollStatus = .error
//        }
    }
    
    /// Asynchronously upload a report and its vehicle image to Google Firestore and Firebase Storage
    /// - Parameters:
    ///   - report: The report object to be encoded and uploaded.
    ///   - image: The optional image to be unwrapped and uploaded
    func uploadReport(_ report: Report, image: UIImage? = nil) async throws {
        try await FirebaseAuthManager.manager.userCanPerformAction()
        try await ReportManager.manager.upload(report, image: image)
        await fetchReports()
    }
    
    /// Update a original report
    /// - Parameters:
    ///   - originalReportId: The UUID of the original report
    ///   - update: The Update object
    func addUpdateToOriginalReport(originalReport: Report, report: Report, vehicleImage: UIImage? = nil) async throws {
        try await FirebaseAuthManager.manager.userCanPerformAction(uid: originalReport.uid)
        guard let uid = Auth.auth().currentUser?.uid else {
            throw ReportManagerError.error
        }
        
        guard try await ReportManager.manager.reportDoesExist(originalReport.id) else {
            throw ReportManagerError.doesNotExist
        }
                
        var report = report
        report.imageURL = try await StorageManager.shared.saveVehicleImage(vehicleImage, reportType: report.reportType, id: report.id)
        
        let update = Update(uid: uid, type: report.reportType, vehicle: report.vehicle, reportId: report.id, dt: report.dt, vehicleImageUrl: report.imageURL)
        let updateId = try await ReportManager.manager.appendUpdateToReport(originalReport.role.associatedValue, update: update)
        
        report.updateId = updateId
        
        try await uploadReport(report)
    }
    
    func deleteReport(report: Report) async throws {
        try await FirebaseAuthManager.manager.userCanPerformAction()
        try await ReportManager.manager.delete(report)
        Task {
            await fetchReports()
        }
    }
    
    func getNumberOfReportUpdates(report: Report) async -> Int {
        return await ReportManager.manager.getNumberOfUpdates(report)
    }
    
    deinit {
        print("Dead: ReportsViewModel")
    }
}
