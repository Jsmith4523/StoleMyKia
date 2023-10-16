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
    }
    
    func didReceive(_ notification: UNNotification) {
        let userInfo = notification.request.content.userInfo
        
        if let vehicleImageString = userInfo["imageUrl"] as? String {
            self.getVehicleImage(urlString: vehicleImageString)
        }
    }
    
    ///Download the vehicle image from firebase
    private func getVehicleImage(urlString: String) {
        
    }
}
