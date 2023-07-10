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

    @Published private(set) var reports = [Report]() {
        didSet {
            delegate?.reportsDelegate(didReceieveReports: reports)
        }
    }
    
    private let manager = ReportManager.manager

    weak var delegate: ReportsDelegate?
    weak var firebaseUserDelegate: FirebaseUserDelegate?
    
    override init() {
        super.init()
    }
    
    func fetchReports() async {
        do {
            self.reports = try await manager.fetch()
        } catch {
            
        }
    }
    
    func deleteReport(report: Report) async throws {
        try await manager.delete(report.id, path: report.vehicleImagePath)
    }
    
    deinit {
        print("Dead: ReportsViewModel")
    }
}

enum FetchReportError: String, Error {
    case unavaliable = "This report is unavaliable at the moment."
    case deleted = "This report was deleted."
    
    var title: String {
        switch self {
        case .unavaliable:
            return "Unavaliable!"
        case .deleted:
            return "Deleted!"
        }
    }
    
    var image: String {
        switch self {
        case .unavaliable:
            return "doc"
        case .deleted:
            return "trash"
        }
    }
}


//MARK: - LicenseScannerDelegate
extension ReportsViewModel: LicenseScannerDelegate {
    func fetchReportsWithLicense(_ licenseString: String) async throws -> [Report] {
        return [Report]()
    }
}
