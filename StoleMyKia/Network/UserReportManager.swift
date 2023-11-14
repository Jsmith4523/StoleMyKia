//
//  UserReportManager.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/3/23.
//

import Foundation
import Firebase

final class UserReportsManager {
    
    enum UserReportsManagerError: Error {
        case userError
        case codableError
    }
    
    static let shared = UserReportsManager()
    
    private init() {}
    
    /// Retrieves reports from firebase created by the signed in user
    /// - Returns: Reports made by the user.
    func fetchUserReports() async throws -> [Report] {
        guard let currentUser = Auth.auth().currentUser else {
            throw UserReportsManagerError.userError
        }
        
        let documents = try await Firestore.firestore()
            .collection(FirebaseDatabasesPaths.reportsDatabasePath)
            .whereField("uid", isEqualTo: currentUser.uid)
            .getDocuments()
            .documents
    
        let data = documents
            .compactMap({$0})
            .map({$0.data()})
        
        do {
            let reports = try data
                .map({try JSONSerialization.data(withJSONObject: $0)})
                .map({try JSONDecoder().decode(Report.self, from: $0)})
            return reports
        } catch {
            throw UserReportsManagerError.codableError
        }
    }
    
    func fetchUserBookmarks() async throws -> [Report] {
        guard let currentUser = Auth.auth().currentUser else {
            throw UserReportsManagerError.userError
        }
        
        let documents = try await Firestore.firestore()
            .collection(FirebaseDatabasesPaths.usersDatabasePath)
            .document(currentUser.uid)
            .collection(FirebaseDatabasesPaths.userBookmarksPath)
            .getDocuments()
            .documents
        
        let reportIds = documents
            .compactMap({$0})
            .map({$0.data()})
            .map({$0["id"] as! String})
        
        var reports = [Report]()
        
        for id in reportIds {
            if let uuid = UUID.ID(uuidString: id), let report = try await ReportManager.manager.fetchSingleReport(uuid, errorIfUnavaliable: false) {
                reports.append(report)
            }
        }
        
        return reports
    }
}
