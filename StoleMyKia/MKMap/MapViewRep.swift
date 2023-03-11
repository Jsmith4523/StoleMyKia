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
    
    
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.showsCompass      = false
        mapView.showsUserLocation = true
        mapView.isRotateEnabled   = false
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        
    }
    
    typealias UIViewType = MKMapView
    
}
