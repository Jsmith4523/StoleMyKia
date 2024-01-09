//
//  NotificationService.swift
//  SMKNotificationService
//
//  Created by Jaylen Smith on 7/29/23.
//

import UserNotifications
import CoreLocation
import UIKit

class NotificationService: UNNotificationServiceExtension { 

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            let apnsData = request.content.userInfo
            
            guard let notificationType = apnsData["notificationType"] as? String else {
                contentHandler(bestAttemptContent)
                return
            }
            
            switch notificationType {
            case "Report":
                handleContentWithReport(bestAttemptContent)
            case "Update":
                handleContentWithUpdate(bestAttemptContent)
            default:
                contentHandler(bestAttemptContent.mutableCopy() as! UNNotificationContent)
            }
            
            if let imageUrlString = apnsData["imageURL"] as? String, let imageUrl = URL(string: imageUrlString) {
                downloadAndAttachImage(from: imageUrl, to: bestAttemptContent)
            } else {
                contentHandler(bestAttemptContent)
            }
        }
        
        func handleContentWithUpdate(_ bestAttemptContent: UNMutableNotificationContent) {
            guard let latitudeString = bestAttemptContent.userInfo["lat"] as? String, let longitudeString = bestAttemptContent.userInfo["long"] as? String, let latitude = Double(latitudeString), let longitude = Double(longitudeString) else {
                contentHandler(bestAttemptContent)
                return
            }
            
            let location = CLLocation(latitude: latitude, longitude: longitude)
            
            //If the location of the report is near the user's current location
            //Inform through the content
            let (isNearby, distance) = location.isCloseToUser()
            
            if let distance, isNearby, distance <= 0.35 {
                let vehicleDetails = bestAttemptContent.userInfo["vehicleDetails"]
                bestAttemptContent.title = "🚨 \(bestAttemptContent.title)"
                bestAttemptContent.body = "The \(vehicleDetails ?? "vehicle") has been reported near your current location! An update indicates that a report regarding your vehicle is \(String(format: "%.2f", distance)) mi. away from your current location."
            }
        }
        
        func handleContentWithReport(_ bestAttemptContent: UNMutableNotificationContent) {
            guard let latitudeString = bestAttemptContent.userInfo["lat"] as? String, let longitudeString = bestAttemptContent.userInfo["long"] as? String, let latitude = Double(latitudeString), let longitude = Double(longitudeString) else {
                contentHandler(bestAttemptContent)
                return
            }
            
            let location = CLLocation(latitude: latitude, longitude: longitude)
            
            //If the location of the report is near the user's current location
            //Inform through the content
            let (isNearby, distance) = location.isCloseToUser()
            
            guard isNearby else {
                contentHandler(bestAttemptContent)
                return
            }
            
            bestAttemptContent.interruptionLevel = .timeSensitive
                        
            if let distance {
                bestAttemptContent.title = "🚨 \(bestAttemptContent.title) \(distance <= 0.025 ? "(NEARBY)" : "(\(String(format: "%.2f", distance)) mi. away)")"
            } else {
                bestAttemptContent.title = "🚨 \(bestAttemptContent.title)"
            }
        }
    }
    
    private func downloadAndAttachImage(from url: URL, to content: UNMutableNotificationContent) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let fileURL = self.saveAttachmentImageForPersistence(data: data) {
                if let attachment = try? UNNotificationAttachment(identifier: "image", url: fileURL, options: nil) {
                    content.attachments = [attachment]
                    content.userInfo["attachment_url"] = fileURL.absoluteString
                }
            }
            if let contentHandler = self.contentHandler {
                contentHandler(content.mutableCopy() as! UNNotificationContent)
            }
        }
        task.resume()
    }
    
    private func saveAttachmentImageForPersistence(data: Data) -> URL? {
        let fileManager = FileManager.default
        let temporaryFolder = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        let imageFileURL = temporaryFolder?.appendingPathComponent("downloadedImage.jpg")
        
        guard let imageFileURL else { return nil }
        
        try? data.write(to: imageFileURL)
        return imageFileURL
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}


private extension CLLocation {
    
    func isCloseToUser() -> (Bool, Double?) {
        guard let userLocation = CLLocationManager().location else {
            return (false, nil)
        }
        
        let distance = ((self.distance(from: userLocation)) * 0.000621371)

        guard distance <= 1.75 else {
            return (false, nil)
        }
        
        return (true, distance)
    }
}
