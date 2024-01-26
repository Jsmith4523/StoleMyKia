//
//  ReportMap.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 4/9/23.
//

import Foundation
import MapKit
import SwiftUI


///Represents a single report for SelectedReportDetailView
struct ReportDetailMapView: UIViewRepresentable {
    
    var selectAnnotation = false
    let report: Report
        
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.mapType = .mutedStandard
        mapView.tintColor = .systemBlue
        mapView.showsUserLocation = true
        mapView.isUserInteractionEnabled = false
        
        if report.discloseLocation {
            let circle = TimelineDiscloseCircle(center: report.location.coordinates, radius: report.role.discloseRadiusSize)
            circle.report = report
            mapView.addOverlay(circle)
            mapView.setVisibleMapRect(circle.boundingMapRect, edgePadding: MKCircle.discloseLocationEdgePadding, animated: false)
        } else {
            let annotation = ReportAnnotation(report: report)
            mapView.addAnnotation(annotation)
            mapView.setRegion(report.location.region, animated: true)
        }
        
        return mapView
    }
    
    func makeCoordinator() -> ReportDetailMapViewCoordinator {
        ReportDetailMapViewCoordinator(reportType: report.reportType)
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {}
    
    typealias UIViewType = MKMapView
    
    final class ReportDetailMapViewCoordinator: NSObject, MKMapViewDelegate {
        
        private var reportType: ReportType
        
        init(reportType: ReportType) {
            self.reportType = reportType
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if let annotation = annotation as? ReportAnnotation {
                let annotationView = ReportTimelineAnnotationView(annotation: annotation)
                return annotationView
            }
            return nil
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let circleOverlay = overlay as? MKCircle {
                let overlayRenderer = MKCircleRenderer(overlay: circleOverlay)
                overlayRenderer.fillColor = reportType.annotationColor.withAlphaComponent(0.25)
                return overlayRenderer
            }
            
            return MKOverlayRenderer()
        }
    }
}
