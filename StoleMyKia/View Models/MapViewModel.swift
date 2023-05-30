//
//  MapViewModel.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 4/9/23.
//

import Foundation
import MapKit
import SwiftUI

final class MapViewModel: NSObject, ObservableObject {
    
    @Published var regionDidChange = false
    @Published var alertLocationSettingsDisabled = false
    
    @Published private var mapViewDidFinishLoading = false
    
    var locationAuth: CLAuthorizationStatus! {
        locationManager.authorizationStatus
    }

    var userLocation: CLLocation! {
        locationManager.location
    }
    
    override init() {
        super.init()
                
        locationManager.delegate = self
        mapView.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
    }
    
    let mapView = MKMapView()
    let locationManager = CLLocationManager()
    
    weak var annotationDelegate: SelectedReportAnnotationDelegate?
    
}

//MARK: - ReportsDelegate
extension MapViewModel: ReportsDelegate {
    func reportsDelegate(didDeleteReport report: Report) {
        mapView.removeAnnotation(report)
    }
    
    func reportsDelegate(didReceieveReports reports: [Report]) {
        mapView.createAnnotations(reports)
    }
}


//MARK: - CLLocationManagerDelegate
extension MapViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            centerToUsersLocation()
        case .authorizedAlways:
            centerToUsersLocation()
        default:
            break
        }
    }
    
    func centerToUsersLocation(animate: Bool = false) {
        guard let userLocation, locationAuth.isAuthorized() else {
            alertLocationSettingsDisabled.toggle()
            return
        }
        
        mapView.setRegion(MKCoordinateRegion(center: userLocation.coordinate, span: .init(latitudeDelta: 0.35, longitudeDelta: 0.35)), animated: animate)
    }
}

//MARK: - MKMapViewDelegate
extension MapViewModel: MKMapViewDelegate {
   
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        
        guard let annotation = annotation as? ReportAnnotation else { return nil}
        
        let annotationView = ReportAnnotationView(annotation: annotation, reuseIdentifier: annotation.report.type)
        annotationView.setCalloutDelegate(self)
        
        return annotationView
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        self.mapViewDidFinishLoading = true
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        guard mapView.selectedAnnotations.isEmpty, mapViewDidFinishLoading else {
            return
        }
        
        withAnimation {
            regionDidChange = true
        }
    }
   
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        switch annotation {
        case let reportsClusterAnnotation as ReportClusterAnnotation:
            UIImpactFeedbackGenerator().impactOccurred(intensity: 7)
            annotationDelegate?.didSelectCluster(reportsClusterAnnotation.reportAnnotations.map({$0.report}))
            mapView.deselectAnnotation(reportsClusterAnnotation, animated: false)
        case let userAnnotation as MKUserLocation:
            mapView.deselectAnnotation(userAnnotation, animated: false)
        default:
            return
        }
    }
    
    func moveToCenter(for coordinates: CLLocationCoordinate2D?) {
        if let coordinates {
            mapView.setCenter(coordinates, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
        ReportClusterAnnotation(memberAnnotations: memberAnnotations)
    }
}

//MARK: - AnnotationCalloutDelegate
extension MapViewModel: AnnotationCalloutDelegate {
    func annotationCallout(annotation: ReportAnnotation) {
        self.annotationDelegate?.didSelectReport(annotation.report)
    }
}
