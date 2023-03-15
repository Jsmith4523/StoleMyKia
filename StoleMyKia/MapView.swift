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
    @State private var isShowingMapOptionsView = false
        
    @EnvironmentObject var reportModel: ReportsViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                MapViewRep()
            }
            .navigationTitle("Reports")
            .navigationBarTitleDisplayMode(.inline)
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
                    Button {
                        isShowingMapOptionsView.toggle()
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingNewReportView) {
            NewReportView()
                .accentColor(.accentColor)
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
