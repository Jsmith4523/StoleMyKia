//
//  MapView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/11/23.
//

import SwiftUI

struct MapView: View {
    
    @State private var isShowingMapOptionsView = false
    
    @EnvironmentObject var reportModel: ReportsViewModel
    
    var body: some View {
        NavigationView {
            MapViewRep()
                .navigationTitle("Reports")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            isShowingMapOptionsView.toggle()
                        } label: {
                            Image(systemName: "ellipsis")
                        }
                    }
                    if reportModel.locationAuthorizationStatus.isAuthorized() {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                reportModel.moveToCenter(for: reportModel.userLocation.coordinate)
                            } label: {
                                Image(systemName: "location")
                            }
                        }
                    }
                }
        }
        .environmentObject(reportModel)
        .sheet(isPresented: $isShowingMapOptionsView) {
            
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .environmentObject(ReportsViewModel())
    }
}
