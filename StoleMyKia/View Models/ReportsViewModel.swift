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
        //self.getReports()
    }
    
     func upload(_ report: Report, with image: UIImage? = nil, completion: @escaping ((Bool)->Void)) {
         //Check uid before uploading a report...
//         guard let uid = firebaseUserDelegate?.uid else {
//             completion(false)
//             return
//         }
//
//        var report = report
//        report.uid = uid
//
//        guard !(report.uid == nil) else {
//            completion(false)
//            return
//        }
        
        manager.uploadReport(report: report, image: image) { [weak self] result in
            switch result {
            case .success(_):
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                completion(true)
                self?.getReports()
                return
            case .failure(let error):
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                completion(false)
                print(error.localizedDescription)
                return
            }
        }
    }

    ///Will retrieve latest reports from Google Firestore
    func getReports() {
        isFetchingReports = true
        manager.fetchReports { [weak self] result in
            switch result {
            case .success(let reports):
                self?.reports = reports
            case .failure(let reason):
                print(reason.localizedDescription)
            }
            self?.isFetchingReports = false
        }
    }
    
    func deleteReport(_ report: Report, completion: @escaping ((Bool)->Void)) {
        manager.delete(report: report) { status in
            switch status {
            case .success(_):
                completion(true)
                removeReportAndAnnotation(report)
            case .failure(_):
                completion(false)
            }
        }
        
        func removeReportAndAnnotation(_ report: Report) {
            self.delegate?.reportsDelegate(didDeleteReport: report)
            self.reports.removeReport(report)
            self.getReports()
        }
    }
    
    func getReportDetails(_ uuid: UUID, completion: @escaping (Result<Report, FetchReportError>) -> Void) {
        manager.fetchReport(uuid) { result in
            switch result {
            case .success(let report):
                completion(.success(report))
            case .failure(let error):
                completion(.failure(error))
            }
        }
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

//MARK: - SelectedReportAnnotationDelegate
extension ReportsViewModel: ReportAnnotationDelegate {
    func didSelectReport(_ report: Report) {
        
    }
    
    func didSelectCluster(_ reports: [Report]) {
        
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
    
    func reportDoesExist(uuid: UUID, completion: @escaping (Bool) -> Void) {
        self.manager.reportDoesExist(uuid: uuid) { result in
            completion(result)
        }
    }
    
    func getUserUpdates(completion: @escaping (Result<[Report], URReportsError>) -> Void) {
        guard let uuids = firebaseUserDelegate?.updates else {
            completion(.success([]))
            return
        }
        
        self.manager.fetchUserUpdates(uuids) { result in
            switch result {
            case .success(let reports):
                completion(.success(reports))
            case .failure(let error):
                completion(.failure(.error(error.localizedDescription)))
            }
        }
    }
    
    func getUserBookmarks(removalCompletion: @escaping RemovalCompletion, completion: @escaping (Result<[Report], URReportsError>) -> Void) {
        guard let uuids = firebaseUserDelegate?.bookmarks else {
            completion(.success([]))
            return
        }
        
        self.manager.fetchUserBookmarkReports(uuids, removalCompletion: { uuid in
            removalCompletion(uuid)
        }){ result in
            switch result {
            case .success(let reports):
                print(reports.count)
                completion(.success(reports))
            case .failure(let error):
                completion(.failure(.error(error.localizedDescription)))
            }
        }
    }
    
    func getUserReports(completion: @escaping ((Result<[Report], URReportsError>) -> Void)) {
        guard let uid = firebaseUserDelegate?.uid else {
            completion(.failure(.userReportsError))
            return
        }
        
        self.manager.fetchUserReports(uid: uid) { result in
            switch result {
            case .success(let reports):
                completion(.success(reports))
            case .failure(let error):
                completion(.failure(.error(error.localizedDescription)))
            }
        }
    }
    
    func deleteAll(completion: @escaping ((Bool) -> Void)) {
        guard let uid = firebaseUserDelegate?.uid else {
            completion(false)
            return
        }
        
        self.manager.deleteUserReports(uid: uid) { status in
            completion(status)
        }
    }
}
