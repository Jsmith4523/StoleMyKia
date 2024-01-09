//
//  NotificationViewController.swift
//  SMKNotificationMapContent
//
//  Created by Jaylen Smith on 12/31/23.
//

import UIKit
import MapKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {
    
    /*If the constraints in the view controller look terrible, then so fucking be it
     MKMapView will not auto-layout for the life of me; so now I have to Dr. Miami this fucking shit
     */
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureMapView()
    }
    
    private func configureMapView() {
        mapView.delegate = self
        mapView.showsUserLocation = true
    }
    
    func didReceive(_ notification: UNNotification) {
        let payload = notification.request.content.userInfo
        var payloadData: PayloadData
        
        if let data = payload["data"] as? [String: Any] {
            guard let data = try? JSONSerialization.data(withJSONObject: data), let payload = try? JSONDecoder().decode(PayloadData.self, from: data) else {
                return
            }
            payloadData = payload
        } else {
            guard let data = try? JSONSerialization.data(withJSONObject: payload), let payload = try? JSONDecoder().decode(PayloadData.self, from: data) else {
                return
            }
            payloadData = payload
        }
        
        switch payloadData.shouldDiscloseLocation {
        case true:
            configureMapViewWithCircleOverlay(payloadData)
        case false:
            configureMapViewWithAnnotation(payloadData)
        }
        
        func configureMapViewWithAnnotation(_ data: PayloadData) {
            let reportAnnotation = ReportAnnotation(coordinate: data.coordinate, vehicleDetails: data.vehicleDetails, reportType: data.reportType)
            mapView.setRegion(data.region, animated: false)
            mapView.addAnnotation(reportAnnotation)
        }
        
        func configureMapViewWithCircleOverlay(_ data: PayloadData) {
            let circleOverlay = ReportOverlay(center: data.coordinate, radius: 1375)
            circleOverlay.reportType = data.reportType
            mapView.addOverlay(circleOverlay)
            mapView.setVisibleMapRect(circleOverlay.boundingMapRect, edgePadding: .init(top: 15, left: 15, bottom: 10, right: 25), animated: false)
            self.displayCircleLabel(data)
        }
    }
    
    private func displayCircleLabel(_ data: PayloadData) {
        let label = CircleOverTextLabel(data: data)
        
        mapView.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -35),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.widthAnchor.constraint(equalToConstant: 300),
            label.heightAnchor.constraint(equalToConstant: 25)
        ])
    }
}

//MARK: - MKMapViewDelegate
extension NotificationViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let reportAnnotation = annotation as? ReportAnnotation {
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
            annotationView.glyphImage = UIImage(systemName: reportAnnotation.reportType.annotationImage)
            annotationView.markerTintColor = reportAnnotation.reportType.annotationColor
            annotationView.subtitleVisibility = .visible
            return annotationView
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let circleOverlay = overlay as? ReportOverlay {
            let overlayRenderer = MKCircleRenderer(overlay: circleOverlay)
            overlayRenderer.fillColor = circleOverlay.reportType.annotationColor.withAlphaComponent(0.25)
            return overlayRenderer
        }
        return MKOverlayRenderer()
    }
}
