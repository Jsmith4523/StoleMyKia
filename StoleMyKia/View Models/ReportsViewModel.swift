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

@MainActor
final class ReportsViewModel: NSObject, ObservableObject {
    
    //MARK: Load Status
    @Published var feedLoadStatus: FeedLoadStatus = .loading
    @Published var localReportsStatus: LocalReportsStatus = .loading

    //MARK: Reports
    @Published var reports = [Report]()
    @Published var localReports = [Report]()
    
    ///Fetch reports locale to the user desired location configuration. Returns latest reports if location is not available.
    func fetchReports(showProgress: Bool = false) async {
        do {
            if showProgress {
                self.feedLoadStatus = .loading
            }
            let fetchedReports = try await ReportManager.manager.fetch()
            self.reports = fetchedReports
            
            guard !(fetchedReports.isEmpty) else {
                self.feedLoadStatus = .empty
                return
            }
            
            self.feedLoadStatus = .loaded
        } catch {
            self.feedLoadStatus = .error
        }
    }
    
    ///Fetch reports local to the users current location
    func fetchLocalReports() async {
        guard CLLocationManager.shared.authorizationStatus.isAuthorized else {
            self.localReportsStatus = .locationDisabled
            return
        }
        
        do {
            let fetchedLocalReports = try await ReportManager.manager.fetchLocalReports()
            self.localReports = fetchedLocalReports
            
            guard !(fetchedLocalReports.isEmpty) else {
                self.localReportsStatus = .empty
                return
            }
            
            self.localReportsStatus = .loaded
        } catch {
            self.localReportsStatus = .error
        }
    }
    
    /// Asynchronously upload a report and its vehicle image to Google Firestore and Firebase Storage
    /// - Parameters:
    ///   - report: The report object to be encoded and uploaded.
    ///   - image: The optional image to be unwrapped and uploaded
    func uploadReport(_ report: Report, image: UIImage? = nil) async throws {
        try await FirebaseAuthManager.manager.userCanPerformAction()
        try await ReportManager.manager.upload(report, image: image)
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
        
        //Checking the associated value so we can ensure the initial report allows for updates
        try await ReportManager.manager.allowsForUpdates(id: originalReport.role.associatedValue)
                
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
