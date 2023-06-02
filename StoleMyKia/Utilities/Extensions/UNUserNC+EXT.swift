//
//  UNUserNC+EXT.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/19/23.
//

import Foundation
import UserNotifications
import UIKit

extension UNUserNotificationCenter {
    
    func notifyOfStolenVehicle(_ report: Report) {
        let content = UNMutableNotificationContent()
        content.title = "Stolen Vehicle"
        //content.body  = "A \(report.vehicleColor.rawValue) \(report.vehicleYear) \(report.vehicleMake.rawValue) \(report.vehicleModel.rawValue)"
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "report", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
}
