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
    
    private let manager = ReportManager.manager

    weak var delegate: ReportsDelegate?
    weak var firebaseUserDelegate: FirebaseUserDelegate?
    
    override init() {
        super.init()
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
    }
    
    func deleteReport(report: Report) async throws {
        try await manager.delete(report.id, path: report.vehicleImagePath)
    }
    
    deinit {
        print("Dead: ReportsViewModel")
    }
}

//MARK: - TimelineMapViewDelegate
extension ReportsViewModel: TimelineMapViewDelegate {
    func getTimelineUpdates(for report: Report) async throws -> [Report] {
        try await manager.fetchUpdates(report)
    }
}


//MARK: - LicensePlateCoordinatorDelegate
extension ReportsViewModel: LicensePlateCoordinatorDelegate {
    func fetchReportsWithLicense(_ licenseString: String) async throws -> [Report] {
        return [Report]()
    }
}
