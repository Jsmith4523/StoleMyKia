//
//  FalseReportManager.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 7/29/23.
//

import Foundation
import FirebaseFirestore

class FalseReportManager {
    
    static let shared = FalseReportManager()
    
    private init() {}
    
    enum FalseReportManagerError: String, Error {
        case codableError = "An internal error occurred with uploading your report. Please try again."
        case uploadError  = "Something went wrong uploading your false report. Please try again."
        case doesNotExist = "That report no longer exists."
    }
    
    private let db = Firestore.firestore()
    
    func uploadFalseReport(_ falseReport: FalseReport) async throws {

        
        guard let jsonData = try falseReport.encodeForUpload() as? [String: Any] else {
            throw FalseReportManagerError.codableError
        }
        
        do {
            try await db.collection("\(FirebaseDatabasesPaths.falseReportsPath)").document(falseReport.uid).collection("Reports").document(falseReport.id.uuidString).setData(jsonData)
        } catch {
            throw FalseReportManagerError.uploadError
        }
    }
}
