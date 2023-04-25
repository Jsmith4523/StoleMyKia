//
//  ReportMap.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 4/9/23.
//

import Foundation
import MapKit
import SwiftUI

struct ReportMap: UIViewRepresentable {
    
    var selectAnnotation = false
    let report: Report
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = false
        mapView.isUserInteractionEnabled = false
        
        if let location = report.location, let coordinates = location.coordinates {
            mapView.setRegion(MKCoordinateRegion(center: coordinates,
                                                 span: .init(latitudeDelta: 0.010, longitudeDelta: 0.010)), animated: false)
        }
        
        if let annotation = ReportAnnotation.createAnnotations([report]).first {
            mapView.addAnnotation(annotation)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
                if selectAnnotation {
                    mapView.selectAnnotation(annotation, animated: true)
                }
            }
        }
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
                let annotationView               = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
                annotationView.animatesWhenAdded = true
                annotationView.glyphImage        = UIImage(systemName: annotation.report.reportType.annotationImage)
                annotationView.markerTintColor   = annotation.report.reportType.annotationColor
                
                return annotationView
            }
            
            return nil
        }
    }
}
