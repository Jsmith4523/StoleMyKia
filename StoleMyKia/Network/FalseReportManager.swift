//
//  FalseReportManager.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 7/29/23.
//

import Foundation
import Firebase

class FalseReportManager {
    
    static let shared = FalseReportManager()
    
    private init() {}
    
    enum FalseReportManagerError: String, Error {
        case codableError = "An internal error occurred with uploading your report. Please try again."
        case uploadError  = "Something went wrong uploading your false report. Please try again."
        case doesNotExist = "That report no longer exists."
    }
        
    func uploadFalseReport(_ falseReport: FalseReport) async throws {
        guard let currentUser = Auth.auth().currentUser else {
            throw FirebaseAuthManager.FirebaseAuthManagerError.userError
        }
        
        try await FirebaseAuthManager.manager.userCanPerformAction()
        
        guard try await ReportManager.manager.reportDoesExist(falseReport.report.id) else {
            throw FalseReportManagerError.doesNotExist
        }
        
        guard let data = try falseReport.encodeForUpload() as? [String: Any] else {
            throw FalseReportManagerError.codableError
        }
        
        try await Firestore.firestore()
            .collection(FirebaseDatabasesPaths.falseReportsPath)
            .document(currentUser.uid)
            .collection(FirebaseDatabasesPaths.userOpenFalseReports)
            .document(falseReport.id.uuidString)
            .setData(data)
    }
}
