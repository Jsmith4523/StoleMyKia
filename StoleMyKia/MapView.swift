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
    
    @StateObject private var mapModel = MapViewModel()
    @EnvironmentObject var reportModel: ReportsViewModel
    
    let imageCache: ImageCache
    
    var body: some View {
        ZStack {
            ZStack(alignment: .bottomTrailing) {
                MapViewRep()
                    .edgesIgnoringSafeArea(.top)
                MapButtons()
            }
            VStack {
                HStack {
                    Text("Reports")
                        .font(.system(size: 35).weight(.heavy))
                    Spacer()
                }
                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $reportModel.isShowingNewReportView) {
            NewReportView()
        }
        .environmentObject(reportModel)
        .environmentObject(mapModel)
        .onAppear {
            reportModel.delegate = mapModel
            mapModel.delegate = reportModel
        }
    }
}

fileprivate struct MapButtons: View {
    
    @EnvironmentObject var mapModel: MapViewModel
    @EnvironmentObject var reportModel: ReportsViewModel
    
    var body: some View {
        HStack {
            Spacer()
            Button {
                reportModel.isShowingNewReportView.toggle()
            } label: {
               Label("New Report", systemImage: "")
                    .padding()
                    .font(.system(size: <#T##CGFloat#>))
                    .foregroundColor(.white)
            }
            Spacer()
//            Button {
//                reportModel.isShowingReportSearchView.toggle()
//            } label: {
//                Image(systemName: "newspaper")
//                    .mapButton()
//            }
//            if mapModel.locationAuth.isAuthorized() {
//                Button {
//                    mapModel.goToUsersLocation(animate: true)
//                } label: {
//                    Image(systemName: "location")
//                        .mapButton()
//                }
//            }
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 30)
        .sheet(isPresented: $reportModel.isShowingReportSearchView) {
            ReportListView()
                .environmentObject(reportModel)
        }
    }
}

private extension Image {
    func mapButton() -> some View {
        return self
            .resizable()
            .scaledToFit()
            .frame(width: 22, height: 22)
            .padding()
            .background(Color.white)
            .clipShape(Circle())
            .shadow(radius: 2)
    }
}

struct Map_Previews: PreviewProvider {
    static var previews: some View {
        MapView(imageCache: ImageCache())
            .environmentObject(ReportsViewModel())
            .environmentObject(MapViewModel())
    }
}
