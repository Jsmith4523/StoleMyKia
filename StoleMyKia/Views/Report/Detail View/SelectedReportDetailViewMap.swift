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
struct SelectedReportDetailViewMap: UIViewRepresentable {
    
    var selectAnnotation = false
    let report: Report
        
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.isUserInteractionEnabled = false
        
        let annotation = ReportAnnotation(report: report)
   
        mapView.addAnnotation(annotation)
        mapView.setRegion(report.location.region, animated: true)
        mapView.selectAnnotation(annotation, animated: false)
        mapView.register(ReportAnnotationView.self, forAnnotationViewWithReuseIdentifier: ReportAnnotation.reusableID)
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    typealias UIViewType = MKMapView
    
    final class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if let annotation = annotation as? ReportAnnotation {
                return ReportAnnotationView(annotation: annotation)
            }
            
            return nil
        }
    }
}
