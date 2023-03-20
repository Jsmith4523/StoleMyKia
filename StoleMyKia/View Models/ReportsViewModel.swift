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
    
    @Published var isShowingSelectedReportView = false
    
    @Published var reports = [Report]() {
        didSet {
            mapView.addAnnotations(ReportAnnotation.createAnnotaitons(for: reports))
        }
    }
    
    @Published var selectedReport: Report!
    
    @Published var locationAuthorizationStatus: CLAuthorizationStatus!

    @Published var userLocation: CLLocation!
    
    //Raw value...
    @AppStorage ("mapType") var mapType = 0
    
    let mapView = MKMapView()
    let locationManager = CLLocationManager()
    
    private var manager = ReportsManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        
        self.getReports()
    }
    
    func upload(_ report: Report) {
        manager.uploadReport(report: report) { result in
            switch result {
            case .success(_):
                return
            case .failure(let error):
                fatalError(error.localizedDescription)
                //return
            }
        }
    }
    
    ///Will retrieve latest reports from Google Firestore
    func getReports() {
        manager.createObserver()
        manager.fetchReports { result in
            switch result {
            case .success(let reports):
                self.reports = reports
            case .failure(let reason):
                print(reason.localizedDescription)
//                fatalError(reason.localizedDescription)
            }
        }
    }
}

//MARK: - CLLocationManagerDelegate
extension ReportsViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.locationAuthorizationStatus = manager.authorizationStatus
        
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
    
    func moveToCenter(for coordinates: CLLocationCoordinate2D?) {
        if let coordinates {
            mapView.setCenter(coordinates, animated: true)
        }
    }
    
    func goToUsersLocation() {
        if let userLocation {
            mapView.setRegion(MKCoordinateRegion(center: userLocation.coordinate, span: .init(latitudeDelta: 0.10, longitudeDelta: 0.10)), animated: true)
        }
    }
}

//MARK: - MKMapViewDelegate
extension ReportsViewModel: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let reportAnnotation = view.annotation as? ReportAnnotation {
            self.selectedReport = reportAnnotation.report
        }
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        if !(self.locationAuthorizationStatus.isAuthorized()) {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        self.selectedReport = nil
    }
    
    func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
        //MARK: This may cause issues later down the road...
        ReportClusterAnnotation(memberAnnotations: memberAnnotations)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        
        if let annotation = annotation as? ReportAnnotation {
           let reportAnnotation = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
            reportAnnotation.glyphImage = UIImage(systemName: annotation.report.reportType.annotationImage)
            reportAnnotation.markerTintColor = annotation.report.reportType.annotationColor
            reportAnnotation.canShowCallout = true
            
            let calloutView = ReportAnnotationCallOut(report: annotation.report)
            calloutView.calloutDelegate = self
            
            reportAnnotation.detailCalloutAccessoryView = calloutView
            
            return reportAnnotation
        }
        
        if let annotation = annotation as? ReportClusterAnnotation {
            let clusterAnnotation = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
            clusterAnnotation.glyphText = "\(annotation.memberAnnotations.count)"
            return clusterAnnotation
        }
        
        return nil
    }
}

//MARK: - RACalloutDelegate
extension ReportsViewModel: RACalloutDelegate {
    func reportAnnotationWillPresentSheet() {
        self.isShowingSelectedReportView.toggle()
    }
}
