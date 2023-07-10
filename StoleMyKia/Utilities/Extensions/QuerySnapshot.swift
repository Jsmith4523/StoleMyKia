//
//  QuerySnapshot.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 7/9/23.
//

import Foundation
import FirebaseFirestore

extension QuerySnapshot {
    
    /// Creates reports from a QuerySnapshot. This method must be used within calls that are only retrieving reports.
    /// - Returns: An array of decoded reports.
    func reportsFromSnapshot() -> [Report] {
        var reports = [Report]()
        
        let documents = self.documents
        
        for document in documents {
            if let report = JSONSerialization.objectFromData(Report.self, jsonObject: document.data()) {
                reports.append(report)
            }
        }
        
        return reports
    }
}
