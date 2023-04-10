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

protocol ReportsDelegate: AnyObject {
    func reportsDelegate(didRecieveReports reports: [Report])
}

protocol SelectedReportDelegate: AnyObject {
    func didSelectReport(_ report: Report)
}

final class ReportsViewModel: NSObject, ObservableObject {
    
    @Published var isShowingNewReportView = false
    @Published var isShowingSelectedReportView = false
    @Published var isShowingReportSearchView = false

    @Published var selectedReport: Report!
    
    @Published var reports = [Report]() {
        didSet {
            delegate?.reportsDelegate(didRecieveReports: reports)
        }
    }
    
    private var manager = ReportsManager()

    weak var delegate: ReportsDelegate?
    
    override init() {
        super.init()
        
        self.getReports()
    }
    
    //TODO: Completion
    ///Upload only the report
    func upload(_ report: Report, with image: UIImage? = nil, completion: @escaping ((Bool)->Void)) {
        manager.uploadReport(report: report, image: image) { result in
            switch result {
            case .success(_):
                completion(true)
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
        manager.fetchReports { result in
            switch result {
            case .success(let reports):
                self.reports = reports
            case .failure(let reason):
                print(reason.localizedDescription)
            }
        }
    }
    
    func deleteReport(_ report: Report) {
        manager.deleteReport(report: report) { status in
            
        }
    }
}

extension ReportsViewModel: SelectedReportDelegate {
    func didSelectReport(_ report: Report) {
        self.isShowingSelectedReportView.toggle()
        self.selectedReport = report
    }
}
