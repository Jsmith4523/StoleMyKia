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

struct MapViewRep: UIViewRepresentable {
    
    @EnvironmentObject var coordinator: MapViewModel
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = context.coordinator.mapView
        
        mapView.showsCompass      = false
        mapView.isRotateEnabled   = false
        mapView.isPitchEnabled    = true
        mapView.showsUserLocation = true
        mapView.showsScale        = true
                        
        return mapView
    }
    
    func makeCoordinator() -> MapViewModel {
        return self.coordinator
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {}
}

