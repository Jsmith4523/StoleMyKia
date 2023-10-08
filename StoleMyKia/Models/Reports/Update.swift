//
//  Update.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 7/30/23.
//

import Foundation

struct Update: Identifiable, Codable {
    
    init(uid: String, type: ReportType, vehicle: Vehicle, reportId: UUID, dt: TimeInterval = Date.now.epoch, vehicleImageUrl: String? = nil) {
        self.uid              = uid
        self.reportId         = reportId
        self.updateReportType = type
        self.vehicleDetails   = vehicle.vehicleNotificationDetails
        self.dt               = dt
        self.vehicleImageUrl  = vehicleImageUrl
    }
    
    var id = UUID()
    ///The uid of the user updating the report
    ///Both uids will be compared to make sure the original post user is not notified if matches.
    let uid: String
    ///The UUID of the update report.
    let reportId: UUID
    ///The report type of the update report
    let updateReportType: ReportType
    ///The vehicle associated with this update.
    ///This will be just a string value to avoid including sensitive data
    let vehicleDetails: String
    let vehicleImageUrl: String?
    ///The time of the update report
    let dt: TimeInterval
    
    ///Encode this report for appending to a 'Updates' collection
    func encodeForAppending() throws -> Any? {
        let jsonData = try JSONSerialization.createJsonFromObject(self)
        return jsonData
    }
}
