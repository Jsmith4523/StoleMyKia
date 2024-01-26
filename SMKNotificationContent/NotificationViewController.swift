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
    
    private let placeholderImage = UIImage(named: "vehicle-placeholder")
                
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.contentMode = .scaleAspectFill
    }
    
    func didReceive(_ notification: UNNotification) {
        let userInfo = notification.request.content.userInfo
        
        if let attachment = notification.request.content.attachments.first, attachment.url.startAccessingSecurityScopedResource() {
            let image = self.retrieveImageAttachment(attachment.url.path())
            
            DispatchQueue.main.async {
                self.imageView.image = image
            }
            
            attachment.url.stopAccessingSecurityScopedResource()
        } else {
            guard let urlString = userInfo["imageURL"] as? String else {
                DispatchQueue.main.async {
                    self.imageView.image = self.placeholderImage
                }
                return
            }
            downloadAndSaveImage(urlString)
        }
    }
    
    private func retrieveImageAttachment(_ path: String) -> UIImage? {
        let manager = FileManager.default
        guard manager.fileExists(atPath: path) else { return nil }
        
        guard let data = manager.contents(atPath: path), let image = UIImage(data: data) else { return nil }
        return image
    }
    
    private func downloadAndSaveImage(_ urlString: String?) {
        guard let urlString, let url = URL(string: urlString) else {
            self.imageView.image = placeholderImage
            return
        }
        
        if let image = getImage() {
            self.imageView.image = image
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, err in
            guard let data, (err == nil) else {
                DispatchQueue.main.async {
                    self?.imageView.image = self?.placeholderImage
                }
                return
            }
            
            guard let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    self?.imageView.image = self?.placeholderImage
                }
                return
            }
            
            DispatchQueue.main.async {
                self?.imageView.image = image
                saveImage(imageData: data)
            }
        }
        .resume()
        
        func saveImage(imageData data: Data) {
            UserDefaults.standard.setValue(data, forKey: urlString)
        }
        
        func getImage() -> UIImage? {
            guard let imageData = UserDefaults.standard.data(forKey: urlString), let image = UIImage(data: imageData) else {
                return nil
            }
            return image
        }
    }
}
