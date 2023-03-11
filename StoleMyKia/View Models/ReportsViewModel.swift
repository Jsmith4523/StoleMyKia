//
//  ReportsViewModel.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/11/23.
//

import Foundation
import SwiftUI
import UIKit
import MapKit

final class ReportsViewModel: NSObject, ObservableObject {
    
    @Published var reports = [Report]()
    
    @Published var selectedReport: Report!
    
    @Published var locationAuthorizationStatus: CLAuthorizationStatus!
    
    @Published var userLocation: CLLocation! {
        didSet {
            mapView.setCenter(userLocation.coordinate, animated: true)
        }
    }
    
    let mapView = MKMapView()
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        
        locationAuthorizationStatus = locationManager.authorizationStatus
        locationManager.delegate = self
    }
    
    
    func moveToCenter(for coordinates: CLLocationCoordinate2D) {
        mapView.setCenter(coordinates, animated: true)
    }
}

extension ReportsViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            self.userLocation = locationManager.location
        case .authorizedAlways:
            self.userLocation = locationManager.location
        default:
            break
        }
    }
}

extension ReportsViewModel: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let reportAnnotation = view.annotation as? ReportAnnotation {
            self.selectedReport = reportAnnotation.report
            mapView.setCenter(reportAnnotation.coordinate, animated: true)
        }
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        if !(self.locationAuthorizationStatus.isAuthorized()) {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }

        if let annotation = annotation as? ReportAnnotation {
            let reportAnnotation             = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
            reportAnnotation.glyphImage      = UIImage(named: annotation.report.reportType.annotationImage)
            reportAnnotation.markerTintColor = annotation.report.reportType.annotationColor

            return reportAnnotation
        }
        return nil
    }
}

extension CLAuthorizationStatus {
    
    
    func isAuthorized() -> Bool {
        self == .authorizedWhenInUse || self == .authorizedAlways
    }
}
