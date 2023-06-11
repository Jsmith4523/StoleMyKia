//
//  FirebaseUserNotification.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/9/23.
//

import Foundation

///Custom notification object firebase creates and sends off when a notification comes in through AppDelegate
struct FirebaseUserNotification: Identifiable, Codable {
    
    var id = UUID()
    ///The UUID of the report. Firebase will fetch to see if the report is still avaliable.
    let reportId: UUID
    let dt: TimeInterval
    let vehicle: Vehicle
    let reportType: ReportType
    var didRead: Bool = false
}
