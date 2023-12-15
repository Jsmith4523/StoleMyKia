//
//  NotificationRadiusMapView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 9/20/23.
//

import Foundation
import SwiftUI
import UIKit
import MapKit

struct NotificationRadiusMapView: UIViewRepresentable {
    
    var userInteractionEnabled: Bool = true
    
    @Binding var location: UserNotificationSettings.UserNotificationLocation?
    
    @ObservedObject var radiusMapViewCoordinator: NotificationRadiusMapViewCoordinator = .init()
    
    typealias UIViewType = MKMapView
    
    let mapView = MKMapView()
        
    func makeUIView(context: Context) -> MKMapView {
        let mapView = self.mapView
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.isUserInteractionEnabled = userInteractionEnabled
        mapView.isPitchEnabled = false
        mapView.isRotateEnabled = false
        
        if let location {
            let notificationCircleOverlay = MKCircle(center: location.coordinate, radius: location.radius)
            mapView.addOverlay(notificationCircleOverlay)
            mapView.setVisibleMapRect(notificationCircleOverlay.boundingMapRect, edgePadding: .init(top: 50, left: 50, bottom: 50, right: 50), animated: false)
        }
        
        return mapView
    }
    
    func makeCoordinator() -> NotificationRadiusMapViewCoordinator {
        let coordinator = self.radiusMapViewCoordinator
        coordinator.radiusMapView = self.mapView
        return coordinator
    }
    
    static func dismantleUIView(_ uiView: MKMapView, coordinator: ()) {
        uiView.removeOverlays(uiView.overlays)
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {}
}

final class NotificationRadiusMapViewCoordinator: NSObject, MKMapViewDelegate, ObservableObject {
    
    @Published private(set) var location: UserNotificationSettings.UserNotificationLocation?
    
    private let locationManager = CLLocationManager()
        
    weak var radiusMapView: MKMapView?
    
    func setCurrentLocation(_ location: UserNotificationSettings.UserNotificationLocation) {
        self.location = location
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let circleOverlay = overlay as? MKCircle {
            let overlayRenderer = MKCircleRenderer(overlay: circleOverlay)
            overlayRenderer.fillColor = .systemBlue.withAlphaComponent(0.40)
            overlayRenderer.strokeColor = .systemBlue
            overlayRenderer.lineWidth = 1.65
            return overlayRenderer
        }
        
        return MKOverlayRenderer()
    }
    
    func setNotificationRegion(center: CLLocationCoordinate2D? = nil, radius: Double = NearbyDistance.fiveMiles.distance) {
        if let mapView = radiusMapView {
            mapView.removeOverlays(mapView.overlays)
            
            let center: CLLocationCoordinate2D = center ?? mapView.centerCoordinate
            
            let notificationCircleOverlay = MKCircle(center: center, radius: radius)
            mapView.setVisibleMapRect(notificationCircleOverlay.boundingMapRect, edgePadding: .init(top: 50, left: 50, bottom: 50, right: 50), animated: true)
            mapView.addOverlay(notificationCircleOverlay)
            
            self.location = UserNotificationSettings.UserNotificationLocation(lat: center.latitude,
                                                                              long: center.longitude,
                                                                              radius: radius)
        }
    }
    
    ///Set the notification circle to the users current location
    func setNotificationRegionToUserCurrentLocation(radius: Double = NearbyDistance.fiveMiles.distance) {
        locationManager.requestWhenInUseAuthorization()
        
        guard let userLocation = locationManager.usersCurrentLocation else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        
        setNotificationRegion(center: userLocation, radius: radius)
    }
}
