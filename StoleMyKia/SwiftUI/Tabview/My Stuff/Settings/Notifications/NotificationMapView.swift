//
//  NotificationMapView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 9/20/23.
//

import SwiftUI

struct NotificationMapView: View {
    
    @State private var radiusAmount: Double = NearbyDistance.oneMile.distance
    
    @Binding var location: UserNotificationSettings.UserNotificationLocation?
    
    @StateObject private var radiusMapViewCoordinator = NotificationRadiusMapViewCoordinator()
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack(alignment: .center) {
                    NotificationRadiusMapView(location: $location, radiusMapViewCoordinator: radiusMapViewCoordinator)
                    Image(systemName: "plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                }
                VStack {
                    Slider(value: $radiusAmount, in: NearbyDistance.oneMile.distance...NearbyDistance.allCases.last!.distance) { _ in
                        radiusMapViewCoordinator.setNotificationRegion(center: self.location?.coordinate, radius: radiusAmount)
                    }
                    .disabled(location == nil)
                    HStack {
                        Button {
                            radiusMapViewCoordinator.setNotificationRegion(radius: radiusAmount)
                        } label: {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: 19).bold())
                                .padding()
                                .frame(width: UIScreen.main.bounds.width/2-20)
                                .foregroundColor(Color(uiColor: .systemBackground))
                                .background(Color(uiColor: .label))
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        }
                        Button {
                            radiusMapViewCoordinator.setNotificationRegionToUserCurrentLocation(radius: radiusAmount)
                        } label: {
                            Image(systemName: "location.fill")
                                .font(.system(size: 19).bold())
                                .padding()
                                .frame(width: UIScreen.main.bounds.width/2-20)
                                .foregroundColor(.white)
                                .background(.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Notification Region")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            if let location {
                radiusAmount = location.radius
                radiusMapViewCoordinator.setCurrentLocation(location)
            }
        }
        .onReceive(radiusMapViewCoordinator.$location) { location in
            self.location = location
        }
    }
}

struct NotificationMapView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationMapView(location: .constant(nil))
    }
}
