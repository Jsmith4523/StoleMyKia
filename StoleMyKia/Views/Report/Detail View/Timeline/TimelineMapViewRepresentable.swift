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
    
    private let coordinator = DetailMapViewCoordinator()

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        
        // Registering annotation view class
        mapView.addAnnotation(ReportAnnotation(report: report))
        mapView.register(ReportAnnotationView.self, forAnnotationViewWithReuseIdentifier: ReportAnnotation.reusableID)
        
        return mapView
    }
    
    func makeCoordinator() -> DetailMapViewCoordinator {
        coordinator.report = report
        return coordinator
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {}
    
    class DetailMapViewCoordinator: NSObject, MKMapViewDelegate {
        
        var report: Report!
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if let annotation = annotation as? ReportAnnotation {
                return ReportAnnotationView(annotation: annotation)
            }
            
            return nil
        }
        
        
        deinit {
            print("Dead MKMapViewCoordinator")
        }
    }
}
