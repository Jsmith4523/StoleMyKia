//
//  DetailMapView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/10/23.
//

import Foundation
import MapKit
import SwiftUI

struct TimelineMap: View {
    
    @ObservedObject var viewModel: TimelineMapViewModel
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TimelineMKMapView(viewModel: viewModel)
                .ignoresSafeArea()
        }
    }
}

///This map is used to show the original report and updates over time
struct TimelineMKMapView: UIViewRepresentable {
    
    @ObservedObject var viewModel: TimelineMapViewModel

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        viewModel.mapView = mapView
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.showsCompass = false
        mapView.isRotateEnabled = true
        mapView.isPitchEnabled = false
        mapView.mapType = .mutedStandard
        mapView.tintColor = .systemBlue
        
        mapView.register(ReportTimelineAnnotationView.self, forAnnotationViewWithReuseIdentifier: ReportAnnotation.reusableID)
        
        //Relocating MKCompass
        let compass = MKCompassButton(mapView: mapView)
        compass.compassVisibility = .adaptive
        mapView.addSubview(compass)
        
        compass.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            compass.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -10),
            compass.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -55)
        ])
    
        return mapView
    }
    
    static func dismantleUIView(_ uiView: MKMapView, coordinator: TimelineMapViewModel) {
        uiView.removeAnnotations(uiView.annotations)
        uiView.removeOverlays(uiView.overlays)
        coordinator.mapView = nil
    }
    
    func makeCoordinator() -> TimelineMapViewModel { viewModel }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {}
}
