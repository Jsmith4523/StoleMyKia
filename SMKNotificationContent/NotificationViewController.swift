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
            self.downloadVehicleImage(urlString: vehicleImageString)
        }
    }
    
    ///Download the vehicle image from firebase
    private func downloadVehicleImage(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        Task {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { return }
            imageView.image = image
        }
    }
}
