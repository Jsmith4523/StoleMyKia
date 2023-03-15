//
//  RadiusMapCoordinator.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/13/23.
//

import Foundation
import MapKit
import SwiftUI
import UIKit

protocol NotificationRadiusDelegate: AnyObject {
    var currentRadius: CLLocationDistance? {get set}
}

final class RadiusMapCoordinator: NSObject, ObservableObject {
    
    @Published var alertSetupError = false
    
    @Published private var userLocation: CLLocationCoordinate2D!
    
    @Published var radiusSize: Double = 25000.0 {
        didSet {
            if let userLocation {
                self.radiusCircle = MKCircle(center: userLocation, radius: radiusSize)
                mapView.setVisibleMapRect(radiusCircle.boundingMapRect, edgePadding: self.circlePadding, animated: true)
                notificationDelegate?.currentRadius = radiusSize
            }
        }
    }
        
    let mapView = MKMapView()
    var radiusCircle: MKCircle!
    
    let circlePadding: UIEdgeInsets = .init(top: 25, left: 25, bottom: 25, right: 25)
    
    private let locationManager = CLLocationManager()
    
    weak var notificationDelegate: NotificationRadiusDelegate?
    
    ///Once passed, this will immediately setup the map
    func setNotificationDelegate(_ delegate: NotificationRadiusDelegate) {
        self.notificationDelegate = delegate
        setupMap()
    }
    
    func setupMap() {
        if let userLocation = locationManager.usersCurrentLocation, let radius = notificationDelegate?.currentRadius{
            
            self.userLocation = userLocation
            mapView.region = MKCoordinateRegion(center: userLocation, span: .init(latitudeDelta: 0.5, longitudeDelta: 0.5))
            
            radiusCircle = MKCircle(center: userLocation, radius: radius)
            radiusSize = radius
        } else {
            alertSetupError.toggle()
        }
    }
}

extension RadiusMapCoordinator: MKMapViewDelegate {
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay is MKCircle {
            let boundCircle = MKCircleRenderer(overlay: overlay)
            boundCircle.strokeColor = UIColor.tintColor
            boundCircle.lineWidth = CGFloat(0.90)
            boundCircle.fillColor = UIColor.tintColor.withAlphaComponent(0.18)
            
            return boundCircle
        }
        
        return MKOverlayRenderer(overlay: overlay)
    }
}
