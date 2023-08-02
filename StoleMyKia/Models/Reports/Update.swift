//
//  Update.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 7/30/23.
//

import Foundation

struct Update: Identifiable, Codable {
    
    init(uid: String, authorUid: String, type: ReportType, reportId: UUID, dt: TimeInterval = Date.now.epoch) {
        self.uid              = uid
        self.authorUid        = authorUid
        self.reportId         = reportId
        self.updateReportType = type
        self.dt               = dt
    }
    
    var id = UUID()
    ///The uid of the user updating the report
    ///Both uids will be compared to make sure the original post user is not notified if matches.
    let uid: String
    ///The original report author uid.
    ///The uid is used to retrieve the FCM token from Firebase and send the remote notification to the user.
    let authorUid: String
    ///The UUID of the update report.
    let reportId: UUID
    ///The report type of the update report
    let updateReportType: ReportType
    ///The time of the update report
    let dt: TimeInterval
    
    ///Encode this report for appending to a 'Updates' collection
    func encodeForAppending() throws -> Any? {
        let jsonData = try JSONSerialization.createJsonFromObject(self)
        return jsonData
    }
}
