//
//  NotificationMapView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 9/20/23.
//

import SwiftUI

enum NearbyDistance: String, CaseIterable, Identifiable {
    case oneMile         = "1 Mile"
    case fiveMiles       = "5 Miles"
    case tenMiles        = "10 Miles"
    case twentyFiveMiles = "25 Miles"
    case fiftyMiles      = "50 Miles"
    
    private static let oneMeter = 1609.35
    
    var id: String {
        self.rawValue
    }
    
    var distance: Double {
        switch self {
        case .oneMile:
            return Self.oneMeter
        case .fiveMiles:
           return Self.oneMeter * 5
        case .tenMiles:
           return Self.oneMeter * 10
        case .twentyFiveMiles:
           return Self.oneMeter * 25
        case .fiftyMiles:
            return Self.oneMeter * 50
        }
    }
}

struct NotificationMapView: View {
    
    @State private var showInfoAlert = false
    
    @State private var radiusAmount: Double = NearbyDistance.oneMile.distance
    
    @Binding var location: UserNotificationSettings.UserNotificationLocation?
    
    @StateObject private var radiusMapViewCoordinator = NotificationRadiusMapViewCoordinator()
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack(alignment: .top) {
                    ZStack(alignment: .center) {
                        NotificationRadiusMapView(location: $location, radiusMapViewCoordinator: radiusMapViewCoordinator)
                        Image(systemName: "plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                            .shadow(radius: 2)
                    }
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
            .navigationTitle("Configure Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        self.showInfoAlert.toggle()
                    } label: {
                        Image(systemName: "info.circle")
                    }
                }
            }
            .alert("Navigate to your desired location on the map. Once located and set, you'll receive reports and notifications within that area.", isPresented: $showInfoAlert) {
                Button("OK") {}
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
