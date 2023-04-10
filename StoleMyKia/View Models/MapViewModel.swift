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
        locationManager.delegate = self
    }       
    
    let mapView = MKMapView()
    let locationManager = CLLocationManager()
    
    weak var delegate: SelectedReportDelegate?
}

//MARK: - ReportsDelegate
extension MapViewModel: ReportsDelegate {
    func reportsDelegate(didRecieveReports reports: [Report]) {
        mapView.addAnnotations(ReportAnnotation.createAnnotaitons(reports))
        mapView.removeAnnotations(mapView.annotations.doesNotInclude(reports))
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
    
    func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
        //MARK: This may cause issues later down the road...
        ReportClusterAnnotation(memberAnnotations: memberAnnotations)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        
        if let annotation = annotation as? ReportAnnotation {
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
            annotationView.glyphImage = UIImage(systemName: annotation.report.reportType.annotationImage)
            annotationView.markerTintColor = annotation.report.reportType.annotationColor
            
            //Setting up Callout View
            
            let calloutView = ReportAnnotationCallOut(report: annotation.report)
            calloutView.calloutDelegate = self
            
            annotationView.canShowCallout = true
            annotationView.detailCalloutAccessoryView = calloutView
            
            return annotationView
        }
        
        return nil
    }
}

//MARK: - AnnotationCalloutDelegate
extension MapViewModel: AnnotationCalloutDelegate {
    func annotationCallout(willPresentReport report: Report) {
        self.delegate?.didSelectReport(report)
    }
}
