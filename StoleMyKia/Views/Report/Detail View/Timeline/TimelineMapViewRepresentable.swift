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
        timelineMapCoordinator.mapView = mapView
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.mapType = MapViewType.standard.mapType
        
        // Registering annotation view class
        let annotation = ReportAnnotation(report: report)
        mapView.addAnnotation(annotation)
        mapView.setRegion(annotation.region, animated: false)
        mapView.register(ReportTimelineAnnotationView.self, forAnnotationViewWithReuseIdentifier: ReportAnnotation.reusableID)
    
        return mapView
    }
    
    func makeCoordinator() -> TimelineMapViewCoordinator {
        timelineMapCoordinator
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {}
}

final class TimelineMapViewCoordinator: NSObject, MKMapViewDelegate, ObservableObject {
    
    @Published var mapViewType: MapViewType = .standard {
        didSet {
            mapView?.mapType = mapViewType.mapType
        }
    }
    
    override init() {
        super.init()
        testSetup()
    }
    
    var mapView: MKMapView?
    
    func testSetup() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let mapView = self.mapView {
                mapView.addAnnotation(ReportAnnotation(report: .init(dt: Date.now.epoch, reportType: .located, vehicle: .init(vehicleYear: 2017, vehicleMake: .hyundai, vehicleModel: .elantra, vehicleColor: .red), distinguishableDetails: "", location: .init(lat: 40.74763, lon: -74.00445), role: .original)))
                mapView.addAnnotation(ReportAnnotation(report: .init(dt: Date.now.epoch, reportType: .found, vehicle: .init(vehicleYear: 2017, vehicleMake: .hyundai, vehicleModel: .elantra, vehicleColor: .red), distinguishableDetails: "", location: .init(lat: 40.79072, lon: -74.07032), role: .original)))
                
                let coordinates = mapView.annotations.map { $0.coordinate }
                
                let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
                polyline.title = "Here"
                mapView.addOverlay(polyline)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        
        print("Selected")
        
        if let annotation = annotation as? ReportAnnotation {
            let annotationView = ReportTimelineAnnotationView(annotation: annotation)
            annotationView.canShowCallout = true
            annotationView.detailCalloutAccessoryView = UIView()
            return annotationView
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let lineRenderer = MKPolylineRenderer(polyline: polyline)
            lineRenderer.strokeColor = .systemTeal
            lineRenderer.lineWidth = 3.5
            lineRenderer.lineDashPhase = 0.5
            return lineRenderer
        }
        
        return MKOverlayRenderer()
    }
}






protocol TimelineMapViewDelegate: AnyObject {
    func getTimelineUpdates(for uuid: UUID, completion: @escaping (Result<[Report], Error>) -> Void)
}
