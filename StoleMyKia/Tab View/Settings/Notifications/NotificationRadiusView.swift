//
//  NotificationRadiusView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/13/23.
//

import SwiftUI
import MapKit

struct NotificationRadiusView: View {
    
    @EnvironmentObject var notificationModel: NotificationViewModel
    
    @StateObject private var radiusMapCoordinator = RadiusMapCoordinator()
    
    var body: some View {
        NavigationView {
            VStack {
                RadiusMap()
                    .frame(height: 250)
            }
            .navigationTitle("Notification Radius")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            
        }
    }
}

fileprivate struct RadiusMap: UIViewRepresentable {
    func makeUIView(context: Context) -> MKMapView {
        let mapView = context.coordinator.mapView
        
        mapView.showsUserLocation = true
        mapView.showsCompass = false
        
        return mapView
    }
    
    func makeCoordinator() -> RadiusMapCoordinator {
        RadiusMapCoordinator()
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        
    }
    
    typealias UIViewType = MKMapView
    
}

protocol NotificationRadiusDelegate: AnyObject {
    
    var currentRadius: CLLocationDistance? {get}
}

final class RadiusMapCoordinator: NSObject, MKMapViewDelegate, ObservableObject {
        
    let mapView = MKMapView()
    var radiusCircle = MKCircle()
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        
        if let userLocation = locationManager.usersCurrentLocation {
            mapView.region = MKCoordinateRegion(center: userLocation, span: .init(latitudeDelta: 0.5, longitudeDelta: 0.5))
            //The radius circle will immediately be the center of the users location
        }
    }
}




















struct NotificationRadiusView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationRadiusView()
            .accentColor(.red)
            .environmentObject(NotificationViewModel())
    }
}
