//
//  MapView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/11/23.
//

import SwiftUI
import MapKit

struct MapView: View {
        
    @EnvironmentObject var reportModel: ReportsViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                MapViewRep()
            }
            .navigationTitle("Reports")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if reportModel.locationAuthorizationStatus.isAuthorized() {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            reportModel.goToUsersLocation()
                        } label: {
                            Image(systemName: "location")
                        }
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        
                    } label: {
                        Image(systemName: "plus")
                    }
                    Button {
                        
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
            }
        }
        .environmentObject(reportModel)
        .onAppear {
            reportModel.mapView.addAnnotation(ReportAnnotation(coordinate: CLLocationCoordinate2D(latitude: 38.90220, longitude: -77.02322), report: .init(title: "Stolen", description: "Lorem Ipsum", reportType: .withnessed, vehicleMake: .hyundai, vehicleColor: .gold, vehicleYear: 2017, vehicleDescription: "Elantra", lat: 38.90220, lon: -77.02322)))
            reportModel.mapView.addAnnotation(ReportAnnotation(coordinate: CLLocationCoordinate2D(latitude: 40.90220, longitude: -79.02322), report: .init(title: "Stolen", description: "Lorem Ipsum", reportType: .stolen, vehicleMake: .hyundai, vehicleColor: .gold, vehicleYear: 2017, vehicleDescription: "Elantra", lat: 40.90220, lon: -79.02322)))
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .environmentObject(ReportsViewModel())
    }
}
