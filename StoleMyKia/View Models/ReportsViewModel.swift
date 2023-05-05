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
    @Published var isShowingNewReportView = false
    @Published var isShowingSelectedReportView = false
    @Published var isShowingReportSearchView = false

    @Published var selectedReport: Report!
    
    @Published var reports = [Report]() {
        didSet {
            delegate?.reportsDelegate(didReceieveReports: reports)
        }
    }
    
    private var manager = ReportsManager()

    weak var delegate: ReportsDelegate?
    weak var firebaseUserDelegate: FirebaseUserDelegate?
    
    override init() {
        super.init()
        
        self.getReports()
    }
    
     func upload(_ report: Report, with image: UIImage? = nil, completion: @escaping ((Bool)->Void)) {
        var report = report
        report.uid = self.firebaseUserDelegate?.uid
        
         //Before uploading, check if the uid has been set
        guard !(report.uid == nil) else {
            completion(false)
            return
        }
        
        manager.uploadReport(report: report, image: image) { result in
            switch result {
            case .success(_):
                completion(true)
                self.getReports()
                return
            case .failure(let error):
                completion(false)
                print(error.localizedDescription)
                return
            }
        }
    }

    ///Will retrieve latest reports from Google Firestore
    func getReports() {
        isFetchingReports = true
        manager.fetchReports { result in
            switch result {
            case .success(let reports):
                self.reports.including(with: reports)
                print(self.reports.map({$0.id}))
            case .failure(let reason):
                print(reason.localizedDescription)
            }
            self.isFetchingReports = false
        }
    }
    
    private func fetchUserReports(completion: @escaping ((Result<[Report], Error>)->Void)) {
        guard let uid = firebaseUserDelegate?.uid else {
            completion(.failure(UserReportsError.error("UID is not avaliable")))
            return
        }
        manager.fetchUserReports(uid: uid) { status in
            switch status {
            case .success(let reports):
                completion(.success(reports))
            case .failure(_):
                completion(.failure(UserReportsError.error("Unable to retrieve user reports")))
            }
        }
    }
    
    func deleteReport(_ report: Report, completion: @escaping ((Bool)->Void)) {
        manager.delete(report: report) { status in
            switch status {
            case .success(_):
                completion(true)
                self.delegate?.reportsDelegate(didDeleteReport: report)
            case .failure(let error):
                completion(false)
                print("❌ Error removing post: \(error.localizedDescription)")
            }
        }
    }
}

//MARK: - SelectedReportDelegate
extension ReportsViewModel: SelectedReportDelegate {
    func didSelectReport(_ report: Report) {
        self.isShowingSelectedReportView.toggle()
        self.selectedReport = report
    }
}

//MARK: - LicenseScannerDelegate
extension ReportsViewModel: LicenseScannerDelegate {
    func getReportsWithLicense(_ licenseString: String, completion: @escaping ((Result<[Report], LicenseScannerError>) -> Void)) {
        completion(.success(self.reports.matchesLicensePlate(licenseString)))
    }
}

//MARK: - UserReportsDelegate
extension ReportsViewModel: UserReportsDelegate {
    func getUserReports(completion: @escaping ((Result<[Report], Error>) -> Void)) {
        self.fetchUserReports() { result in
            switch result {
            case .success(let reports):
                completion(.success(reports))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}


protocol ReportsDelegate: AnyObject {
    func reportsDelegate(didReceieveReports reports: [Report])
    func reportsDelegate(didDeleteReport report: Report)
}

protocol SelectedReportDelegate: AnyObject {
    func didSelectReport(_ report: Report)
}

protocol FirebaseUserDelegate: AnyObject {
    var uid: String? {get}
}
