//
//  MapViewModel.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 4/9/23.
//

import Foundation
import MapKit

final class MapViewModel: NSObject, ObservableObject {
    
    @Published var locationAuth: CLAuthorizationStatus!
    @Published var userLocation: CLLocation!
    
    override init() {
        super.init()
        
        setupViewClasses()
        
        locationManager.delegate = self
        mapView.delegate = self
    }
    
    let mapView = MKMapView()
    let locationManager = CLLocationManager()
    
    weak var delegate: SelectedReportDelegate?
    
    
    private func setupViewClasses() {
        mapView.register(ReportsClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        mapView.register(ReportAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    }
}

//MARK: - ReportsDelegate
extension MapViewModel: ReportsDelegate {
    func reportsDelegate(didDeleteReport report: Report) {
        
    }
    
    func reportsDelegate(didReceieveReports reports: [Report]) {
        mapView.createAnnotations(reports)
    }
}


//MARK: - CLLocationManagerDelegate
extension MapViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.locationAuth = manager.authorizationStatus
        
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
    
    func goToUsersLocation(animate: Bool = false) {
        if let userLocation {
            mapView.setRegion(MKCoordinateRegion(center: userLocation.coordinate, span: .init(latitudeDelta: 0.35, longitudeDelta: 0.35)), animated: animate)
        }
    }
}

//MARK: - MKMapViewDelegate
extension MapViewModel: MKMapViewDelegate {
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        if !(self.locationAuth.isAuthorized()) {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        
        guard let reportAnnotation = annotation as? ReportAnnotation else { return nil}
        
        let annotationView = ReportAnnotationView(annotation: reportAnnotation,
                                                  reuseIdentifier: reportAnnotation.report.type,
                                                  report: reportAnnotation.report)
        annotationView.setCalloutDelegate(self)
        
        return annotationView
    }
}

//MARK: - AnnotationCalloutDelegate
extension MapViewModel: AnnotationCalloutDelegate {
    func annotationCallout(willPresentReport report: Report) {
        self.delegate?.didSelectReport(report)
    }
}
