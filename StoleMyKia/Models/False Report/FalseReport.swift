//
//  FalseReport.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 7/29/23.
//

import Foundation

enum FalseReportType: String, Identifiable, CaseIterable, Codable {
    
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


struct FalseReport: Identifiable, Codable {
    
    enum Status: Codable {
        case open, close
    }
    
    init(authorUid: String, reporterUid: String, report: Report, type: FalseReportType, comments: String) {
        self.authorUid = authorUid
        self.reporterUid = reporterUid
        self.dt = Date.now.epoch
        self.report = report
        self.falseReportType = type
        self.comments = comments
        self.status = .open
    }
    
    var id = UUID()
    let authorUid: String
    let reporterUid: String
    let dt: TimeInterval
    ///The report associated with this false report
    let report: Report
    ///The type of false report
    let falseReportType: FalseReportType
    ///The users description on why this report is false
    let comments: String
    var status: Status = .open
    var isPunishableOffense: Bool = false
    var adminComments: String?
    
    ///Encodes THIS false report for uploading to firebase
    func encodeForUpload() throws -> Any? {
        try JSONSerialization.createJsonFromObject(self)
    }
}
