//
//  NotificationViewController.swift
//  SMKNotificationContent
//
//  Created by Jaylen Smith on 8/9/23.
//

import UIKit
import UserNotifications
import UserNotificationsUI
import MapKit

class NotificationViewController: UIViewController, UNNotificationContentExtension {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupMapView()
    }
    
    func didReceive(_ notification: UNNotification) {
        let userInfo = notification.request.content.userInfo
        
        guard let reportId = userInfo["reportId"] as? String else { return }
        guard let originalReportId = userInfo["originalId"] as? String else { return }
    }
    
    private func setupMapView() {
        mapView.mapType                  = .mutedStandard
        mapView.showsUserLocation        = true
        mapView.isUserInteractionEnabled = false
    }
}

//MARK: - MKMapViewDelegate
extension NotificationViewController: MKMapViewDelegate {
    
    
}
