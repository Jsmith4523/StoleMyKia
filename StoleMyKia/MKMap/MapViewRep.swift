//
//  MapViewRep.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/11/23.
//

import Foundation
import UIKit
import SwiftUI
import MapKit

struct MapViewRep: UIViewRepresentable {
    
    @EnvironmentObject var reportsModels: ReportsViewModel
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = context.coordinator.mapView
        
        mapView.showsCompass      = false
        mapView.showsUserLocation = true
        mapView.isRotateEnabled   = false
        mapView.delegate = context.coordinator
                
        return mapView
    }
    
    func makeCoordinator() -> ReportsViewModel {
        return reportsModels
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.mapType = .init(rawValue: UInt(context.coordinator.mapType)) ?? .standard
    }
    
    typealias UIViewType = MKMapView
    
}
