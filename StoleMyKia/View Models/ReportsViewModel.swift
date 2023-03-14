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
    
    @Published var userLocation: CLLocation!
    
    let mapView = MKMapView()
    let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        
        locationAuthorizationStatus = locationManager.authorizationStatus
        locationManager.delegate = self
    }
    
    
    func moveToCenter(for coordinates: CLLocationCoordinate2D?) {
        if let coordinates {
            mapView.setCenter(coordinates, animated: true)
        }
    }
    
    func goToUsersLocation() {
        mapView.setRegion(MKCoordinateRegion(center: userLocation.coordinate, span: .init(latitudeDelta: 0.025, longitudeDelta: 0.025)), animated: true)
    }
}

extension ReportsViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            self.userLocation = locationManager.location
            goToUsersLocation()
        case .authorizedAlways:
            self.userLocation = locationManager.location
            goToUsersLocation()
        default:
            break
        }
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        self.userLocation = userLocation.location
    }
    
    func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
        MKClusterAnnotation(memberAnnotations: memberAnnotations)
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
            reportAnnotation.glyphImage      = UIImage(systemName: annotation.report.reportType.annotationImage)
            reportAnnotation.markerTintColor = annotation.report.reportType.annotationColor

            return reportAnnotation
        }
        
        if let annotation = annotation as? MKClusterAnnotation {
            let clusterAnnotation = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
            clusterAnnotation.markerTintColor = .gray
            return clusterAnnotation
        }
        
        return nil
    }
}

extension CLAuthorizationStatus {
    
    func isAuthorized() -> Bool {
        self == .authorizedWhenInUse || self == .authorizedAlways
    }
}
