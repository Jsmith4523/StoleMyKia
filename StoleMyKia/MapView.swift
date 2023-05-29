//
//  MapView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/11/23.
//

import SwiftUI
import MapKit

struct ReportsMapView: View {
    
    @State private var isShowingNewReportView = false
    
    @StateObject private var mapModel = MapViewModel()
    @EnvironmentObject var reportModel: ReportsViewModel
     
    var body: some View {
        CustomNavView(title: "Reports",statusBarColor: .darkContent, backgroundColor: .brand) {
            ZStack(alignment: .top) {
                MapViewRepresentable()
                VStack {
                    UpperMapViewButtons()
                    Spacer()
                    LowerMapViewButtons()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        reportModel.isShowingLicensePlateScannerView.toggle()
                    } label: {
                        Image(systemName: "viewfinder")
                            .foregroundColor(.white)
                            .font(.system(size: 19).weight(.heavy))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        
                    } label: {
                        Image(systemName: "list.dash")
                            .foregroundColor(.white)
                            .font(.system(size: 19).weight(.heavy))
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
        .sheet(isPresented: $reportModel.isShowingNewReportView) {
            NewReportView()
        }
        .fullScreenCover(isPresented: $reportModel.isShowingLicensePlateScannerView) {
            LicensePlateScannerView()
        }
        .environmentObject(reportModel)
        .environmentObject(mapModel)
        .onAppear {
            reportModel.delegate = mapModel
            mapModel.annotationDelegate = reportModel
        }
    }
}

fileprivate struct UpperMapViewButtons: View {
    
    @EnvironmentObject var mapModel: MapViewModel
    @EnvironmentObject var reportModel: ReportsViewModel
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                if mapModel.regionDidChange {
                    Button {
                        withAnimation(.linear) {
                            mapModel.regionDidChange = false
                        }
                    } label: {
                        Label("Search here", systemImage: "map")
                            .padding(10)
                            .font(.system(size: 15).weight(.heavy))
                            .background(Color(uiColor: .secondarySystemBackground))
                            .clipShape(Capsule())
                            .shadow(radius: 3)
                    }
                }
                Button {
                    mapModel.centerToUsersLocation(animate: true)
                } label: {
                    Image(systemName: "location")
                        .padding(10)
                        .font(.system(size: 16).weight(.bold))
                        .background(Color(uiColor: .secondarySystemBackground))
                        .clipShape(Circle())
                        .shadow(radius: 3)
                }
            }
            Spacer()
        }
        .padding()
        .alert("Your location settings have denied locating to your current location. To change the settings, go to Settings>StoleMyKia>Location", isPresented: $mapModel.alertLocationSettingsDisabled) {
            Button("OK") {}
            Button("Change Settings"){
                URL.openApplicationSettings()
            }
        }
    }
}


fileprivate struct LowerMapViewButtons: View {
    
    @EnvironmentObject var mapModel: MapViewModel
    @EnvironmentObject var reportModel: ReportsViewModel
    
    var body: some View {
        HStack {
            Spacer()
            Image(systemName: "note.text.badge.plus")
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
                .padding()
                .foregroundColor(.brand)
                .background(Color(uiColor: .secondarySystemBackground))
                .clipShape(Circle())
                .shadow(radius: 2)
                .padding()
        }
        .padding(.bottom)
    }
}

struct Map_Previews: PreviewProvider {
    static var previews: some View {
        ReportsMapView()
            .environmentObject(ReportsViewModel())
            .environmentObject(MapViewModel())
    }
}
