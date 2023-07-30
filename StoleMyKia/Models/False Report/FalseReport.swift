//
//  FalseReport.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 7/29/23.
//

import Foundation

enum FalseReportType: String, Identifiable, CaseIterable, Encodable {
    
    var id: String {
        return self.rawValue
    }
    
    case misinforming = "Misinformation"
    case invalid      = "Invalid"
    case abusive      = "Abusive"
    case spam         = "Spam"
    
    var description: String {
        switch self {
        case .misinforming:
            return "This report is misinforming. It does not contain information that offers any reasoning."
        case .invalid:
            return "This report is invalid. It does not appear as a report and has no relevance."
        case .abusive:
            return "This report contains abusive content such as extreme vulgar, trolling, and/or more offensive content."
        case .spam:
            return "This report is spam."
        }
    }
}


struct FalseReport: Identifiable, Encodable {
    
    private enum Status: Encodable {
        case open, close
    }
    
    init(uid: String, report: Report, type: FalseReportType, comments: String) {
        self.uid = uid
        self.dt = Date.now.epoch
        self.report = report
        self.falseReportType = type
        self.reason = comments
        self.status = .open
    }
    
    var id = UUID()
    let uid: String
    let dt: TimeInterval
    ///The report associated with this false report
    let report: Report
    ///The type of false report
    let falseReportType: FalseReportType
    ///The users description on why this report is false
    let reason: String
    private var status: Status
    private var adminReason: String?
    
    ///Encodes THIS false report for uploading to firebase
    func encodeForUpload() throws -> Any? {
        try JSONSerialization.createJsonFromObject(self)
    }
}
