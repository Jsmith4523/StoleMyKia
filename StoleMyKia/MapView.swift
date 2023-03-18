//
//  MapView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/11/23.
//

import SwiftUI
import MapKit

struct MapView: View {
    
    @State private var isShowingNewReportView = false
        
    @EnvironmentObject var reportModel: ReportsViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                MapViewRep()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if let status = reportModel.locationAuthorizationStatus, status.isAuthorized() {
                        Button {
                            reportModel.goToUsersLocation()
                        } label: {
                            Image(systemName: "location")
                        }
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        isShowingNewReportView.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationTitle("Reports")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $isShowingNewReportView) {
            NewReportView()
        }
        .environmentObject(reportModel)
        .onAppear {
            reportModel.upload(.init(title: "Lorem Ipsum", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.", reportType: .withnessed, vehicleYear: 2016, vehicleMake: .kia, vehicleColor: .red, vehicleModel: .forte, lat: Double.random(in: 50.000...90.000), lon: Double.random(in: 50.000...90.000)))
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .environmentObject(ReportsViewModel())
    }
}
