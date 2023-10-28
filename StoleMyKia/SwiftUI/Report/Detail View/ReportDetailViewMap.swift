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
struct SelectedReportDetailMapView: UIViewRepresentable {
    
    var selectAnnotation = false
    let report: Report
        
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.mapType = .mutedStandard
        mapView.showsUserLocation = true
        mapView.isUserInteractionEnabled = false
        
        if report.discloseLocation {
            let circle = TimelineDiscloseCircle(center: report.location.coordinates, radius: report.role.discloseRadiusSize)
            mapView.addOverlay(circle)
            mapView.setVisibleMapRect(circle.boundingMapRect, edgePadding: MKCircle.discloseLocationEdgePadding, animated: false)
        } else {
            let annotation = ReportAnnotation(report: report)
       
            mapView.addAnnotation(annotation)
            mapView.setRegion(report.location.region, animated: true)

        }
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {}
    
    func makeCoordinator() -> SelectedReportDetailViewMapCoordinator {
       SelectedReportDetailViewMapCoordinator()
    }
    
    typealias UIViewType = MKMapView
    
    final class SelectedReportDetailViewMapCoordinator: NSObject, MKMapViewDelegate {
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
                overlayRenderer.fillColor = MKCircle.discloseLocationFillColor
                return overlayRenderer
            }
            
            return MKOverlayRenderer()
        }
        
        deinit {
            print("Dead: SelectedReportDetailViewMapCoordinator")
        }
    }
}
