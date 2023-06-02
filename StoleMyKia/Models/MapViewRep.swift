//
//  MapViewRep.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 4/10/23.
//

import Foundation
import UIKit
import SwiftUI
import MapKit

struct MapViewRepresentable: UIViewRepresentable {
    
    @EnvironmentObject var coordinator: MapViewModel
    @EnvironmentObject var userModel: UserViewModel
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = context.coordinator.mapView
        
        mapView.showsCompass      = false
        mapView.delegate          = context.coordinator
        mapView.isRotateEnabled   = false
        mapView.isPitchEnabled    = true
        mapView.showsUserLocation = true
        mapView.showsScale        = true
        mapView.tintColor         = .systemBlue
        
        mapView.register(ReportsClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        mapView.register(ReportAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
                        
        return mapView
    }
    
    func makeCoordinator() -> MapViewModel {
        return self.coordinator
    }
    
    static func dismantleUIView(_ uiView: MKMapView, coordinator: MapViewModel) {
        print("Removing map view from superview")
        uiView.delegate = nil
        uiView.removeFromSuperview()
        uiView.removeAnnotations(uiView.annotations)
        uiView.removeOverlays(uiView.overlays)
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
//        if !(userModel.userIsSignedIn) {
//            MapViewRepresentable.dismantleUIView(uiView, coordinator: context.coordinator)
//        }
    }
}

