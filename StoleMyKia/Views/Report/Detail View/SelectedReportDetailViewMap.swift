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
        
        let annotation = ReportAnnotation(report: report)
   
        mapView.addAnnotation(annotation)
        mapView.setRegion(report.location.region, animated: true)
        mapView.register(ReportTimelineAnnotationView.self, forAnnotationViewWithReuseIdentifier: ReportAnnotation.reusableID)
        
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
                annotationView.subtitleVisibility = .hidden
                annotationView.titleVisibility = .hidden
                
                return annotationView
            }
            
            return nil
        }
        
        deinit {
            print("Dead: SelectedReportDetailViewMapCoordinator")
        }
    }
}
