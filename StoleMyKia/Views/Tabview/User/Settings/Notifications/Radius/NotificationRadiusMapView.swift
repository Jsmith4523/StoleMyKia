//
//  NotificationRadiusMapView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/19/23.
//

import Foundation
import SwiftUI
import UIKit
import MapKit

protocol FirebaseUserNotificationRadiusDelegate: AnyObject {
    ///The users current set notification radius
    var usersRadius: Double? {get}
    ///Save the new user radius with completion if successful
    func setNewRadius(_ radius: Double, completion: @escaping (Bool)->Void)
}

struct NotificationRadiusMapView: UIViewRepresentable {
    
    @ObservedObject var radiusMapCoordinator: NotificationRadiusMapViewCoordinator
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        radiusMapCoordinator.mapView = mapView
        mapView.showsUserLocation = true
        mapView.isUserInteractionEnabled = false
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func makeCoordinator() -> NotificationRadiusMapViewCoordinator {
        return radiusMapCoordinator
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {}
}


final class NotificationRadiusMapViewCoordinator: NSObject, ObservableObject {
    
    enum RadiusCoordinatorError: String {
        case locationError = "Your location could not be determined at the moment. Please check your permissions and try again"
        case accountError  = "There was an issue updating your notification radius."
        case genericError  = "We ran into an error with that request."
        case delegateError = "An internal error has occurred. Please notify the developer!"
        case mapViewError  = "An internal map error has occurred. Please notify the developer!"
    }
    
    ///Available notification range
    static let radiusRange: ClosedRange<Double> = 5.00...5000.00
    
    @Published var alertRadiusError = false
    @Published var alertRadiusErrorReason: RadiusCoordinatorError = .genericError
    
    @Published var radius: Double = radiusRange.lowerBound {
        didSet {
            setNewCircleRadius(to: radius)
        }
    }
    
    weak private var firebaseUserRadiusDelegate: FirebaseUserNotificationRadiusDelegate?
    
    var canBeUpdated: Bool {
        guard let firebaseUserRadiusDelegate else {
            return false
        }
        
        //If true, the user cannot update their notification radius.
        //If false, the can update their radius.
        return radius == firebaseUserRadiusDelegate.usersRadius
    }
    
    private var locationManager = CLLocationManager()
    var mapView: MKMapView?
    
    func setDelegate(_ delegate: FirebaseUserNotificationRadiusDelegate) {
        self.firebaseUserRadiusDelegate = delegate
    }
    
    func saveNewRadius(completion: @escaping () -> Void) {
        guard let firebaseUserRadiusDelegate else {
            self.alertRadiusError.toggle()
            self.alertRadiusErrorReason = .delegateError
            return
        }
        
        firebaseUserRadiusDelegate.setNewRadius(radius) { [weak self] success in
            guard success else {
                self?.radius = firebaseUserRadiusDelegate.usersRadius ?? Self.radiusRange.lowerBound
                self?.alertRadiusError.toggle()
                self?.alertRadiusErrorReason = .accountError
                return
            }
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            
            //Dismiss the view once finished
            completion()
        }
    }
    
    private func checkPermissionsWithSetup() {
        guard locationManager.authorizationStatus.isAuthorized else {
            self.alertRadiusError.toggle()
            self.alertRadiusErrorReason = .locationError
            return
        }
        
        self.radius = self.firebaseUserRadiusDelegate?.usersRadius ?? Self.radiusRange.lowerBound
    }
    
    private func setNewCircleRadius(to radius: Double) {
        guard let mapView else {
            self.alertRadiusError.toggle()
            self.alertRadiusErrorReason = .mapViewError
            return
        }
        
        guard let usersLocation = locationManager.location else {
            self.alertRadiusError.toggle()
            self.alertRadiusErrorReason = .locationError
            return
        }
        
        //mapView?.removeOverlays(mapView?.overlays)
        
        let circle = MKCircle(center: usersLocation.coordinate, radius: radius)
        mapView.addOverlay(circle, level: .aboveLabels)
        mapView.setVisibleMapRect(circle.boundingMapRect, animated: true)
    }
    
    deinit {
        mapView = nil
        firebaseUserRadiusDelegate = nil
        print("Dead: NotificationRadiusMapViewCoordinator")
    }
}

//MARK: - MKMapViewDelegate
extension NotificationRadiusMapViewCoordinator: MKMapViewDelegate {
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        self.checkPermissionsWithSetup()
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(circle: overlay)
            circleRenderer.strokeColor = UIColor(Color.brand)
            circleRenderer.fillColor = UIColor(Color.brand).withAlphaComponent(0.25)
            
            return circleRenderer
        }
        
        return MKOverlayRenderer()
    }
}
