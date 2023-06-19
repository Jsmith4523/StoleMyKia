//
//  DetailMapView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/10/23.
//

import Foundation
import MapKit
import SwiftUI

///This map is used to show the original report and updates over time
struct TimelineMapViewRepresentabe: UIViewRepresentable {
    
    ///The report to display
    let report: Report
    
    @ObservedObject var timelineMapCoordinator: TimelineMapViewCoordinator

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        //mapView.isUserInteractionEnabled = false
        
        // Registering annotation view class
        let annotation = ReportAnnotation(report: report)
        mapView.addAnnotation(annotation)
        mapView.selectAnnotation(annotation, animated: true)
        mapView.register(ReportTimelineAnnotationView.self, forAnnotationViewWithReuseIdentifier: ReportAnnotation.reusableID)
    
        return mapView
    }
    
    func makeCoordinator() -> TimelineMapViewCoordinator {
        timelineMapCoordinator
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        context.coordinator.mapView = uiView
    }
}

final class TimelineMapViewCoordinator: NSObject, MKMapViewDelegate, ObservableObject {
    
    ///The avaliable updates for the original reports
    @Published private(set) var updates = [Report]() {
        didSet {
            mapView.createAnnotations(updates)
        }
    }
    
    @Published var isLoading = false
    @Published var alertErrorGettingTimelineUpdates = false
    
    private let locationManager = CLLocationManager()
    
    weak private var timelineMapViewDelegate: TimelineMapViewDelegate?

    func setTimelineMapViewDelegate(_ delegate: TimelineMapViewDelegate) {
        self.timelineMapViewDelegate = delegate
    }
    
    var mapView: MKMapView!

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? ReportAnnotation {
            return ReportTimelineAnnotationView(annotation: annotation)
        }
        return nil
    }
    
    private func setupMapForUpdates() {
        guard let mapView else {
            return
        }
        guard (mapView.annotations.count > 1) else {
            return
        }
        
        let polyline = MKPolyline(coordinates: mapView.annotations.map({$0.coordinate}), count: mapView.annotations.count)
        polyline.title = "Hello"
        polyline.subtitle = "World"
        print("Added")
        mapView.addOverlay(polyline, level: .aboveLabels)
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        setupMapForUpdates()
    }
    
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        if let annotation = annotation as? ReportAnnotation {
            mapView.setRegion(MKCoordinateRegion(center: annotation.report.location.coordinates, span: .init(latitudeDelta: 0.05, longitudeDelta: 0.05)), animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer()
        }
        
        let polylineRenderer = MKMultiPolylineRenderer(overlay: polyline)
        polylineRenderer.strokeColor = .label
        polylineRenderer.lineDashPhase = 2
        polylineRenderer.lineWidth = 1.3
        
        mapView.setVisibleMapRect(polyline.boundingMapRect, animated: true)
        
        return polylineRenderer
    }
    
    func getTimelineUpdates(_ report: Report) {
        self.isLoading = true
        timelineMapViewDelegate?.getTimelineUpdates(for: report.id) { [weak self] result in
            switch result {
            case .success(let updates):
                self?.isLoading = false
                self?.updates = updates
            case .failure(_):
                self?.isLoading = false
                self?.alertErrorGettingTimelineUpdates.toggle()
            }
        }
    }
    
    func goToUsersLocation() {
        guard locationManager.authorizationStatus == .authorizedAlways else {
            return
        }
        
        guard let userLocation = locationManager.location else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        
        let userLocationRegion = MKCoordinateRegion(center: userLocation.coordinate, span: .init(latitudeDelta: 1, longitudeDelta: 1))
        
        mapView.setRegion(userLocationRegion, animated: false)
    }
    
    deinit {
        self.timelineMapViewDelegate = nil
        self.mapView.delegate = nil
        self.mapView.removeAnnotations(mapView.annotations)
        self.mapView.removeOverlays(mapView.overlays)
        self.mapView = nil
        print("Dead: TimelineMapViewCoordinator")
    }
}

protocol TimelineMapViewDelegate: AnyObject {
    
    func getTimelineUpdates(for uuid: UUID, completion: @escaping (Result<[Report], Error>) -> Void)
}
