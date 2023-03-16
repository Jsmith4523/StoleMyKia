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
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                RadiusMap(coordinator: radiusMapCoordinator)
                    .frame(height: 275)
                    .disabled(true)
                VStack(spacing: 20) {
                    Slider(value: $radiusMapCoordinator.radiusSize, in: 25000.0...500000.0)
                    Text(radiusMapCoordinator.radiusSize == 500000.0 ? "You will recieve all notification events you have enabled within and outside the circle" : "Based of your device location, you will only recieve all notification events you have enabled from within the circle.")
                        .multilineTextAlignment(.center)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                Spacer()
            }
            .navigationTitle("Notification Radius")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Done") {
                    dismiss()
                }
            }
            .accentColor(.accentColor)
        }
        .onAppear {
            radiusMapCoordinator.setNotificationDelegate(notificationModel)
        }
        .alert("There was an error", isPresented: $radiusMapCoordinator.alertSetupError) {
            Button("OK") { dismiss ()}
        } message: {
            Text("We ran into a problem on our end. Please contact the developer if this issue continues.")
        }
        .interactiveDismissDisabled()
    }
}

fileprivate struct RadiusMap: UIViewRepresentable {
    
    @ObservedObject var coordinator: RadiusMapCoordinator
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = context.coordinator.mapView
        
        mapView.showsUserLocation = true
        mapView.showsCompass = false
        mapView.delegate = context.coordinator
        
        return mapView
    }
    
    func makeCoordinator() -> RadiusMapCoordinator {
        coordinator
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        if let circle = context.coordinator.radiusCircle {
            if let previousCircle = uiView.overlays.first as? MKCircle {
                uiView.removeOverlay(previousCircle)
            }
            uiView.addOverlay(circle)
            uiView.setVisibleMapRect(circle.boundingMapRect, edgePadding: context.coordinator.circlePadding, animated: true)
        }
    }
    
    typealias UIViewType = MKMapView
    
}





















struct NotificationRadiusView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationRadiusView()
            .accentColor(.red)
            .environmentObject(NotificationViewModel())
    }
}
