//
//  NotificationViewController.swift
//  SMKNotificationContent
//
//  Created by Jaylen Smith on 8/9/23.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {
                
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.contentMode = .scaleAspectFill
    }
    
    func didReceive(_ notification: UNNotification) {
        if let attachment = notification.request.content.attachments.first, attachment.url.startAccessingSecurityScopedResource() {
            let image = self.retrieveImageAttachment(attachment.url.path())
            
            DispatchQueue.main.async {
                self.imageView.image = image
            }
            
            attachment.url.stopAccessingSecurityScopedResource()
        } else {
            
            DispatchQueue.main.async {
                self.imageView.image = UIImage(named: "vehicle-placeholder")
            }
        }
    }
    
    private func retrieveImageAttachment(_ path: String) -> UIImage? {
        let manager = FileManager.default
        guard manager.fileExists(atPath: path) else { return nil }
        
        guard let data = manager.contents(atPath: path), let image = UIImage(data: data) else { return nil }
        return image
    }
}
