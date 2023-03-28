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
                            reportModel.goToUsersLocation(animate: true)
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
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .environmentObject(ReportsViewModel())
    }
}
