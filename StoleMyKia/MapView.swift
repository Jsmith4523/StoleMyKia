//
//  MapView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/11/23.
//

import SwiftUI
import MapKit

struct ReportsMapView: View {
        
    @ObservedObject var mapModel: MapViewModel
    @EnvironmentObject var userModel: UserViewModel
    @EnvironmentObject var reportModel: ReportsViewModel
     
    var body: some View {
        CustomNavView(title: "Reports", statusBarColor: .lightContent, backgroundColor: .brand) {
            ZStack(alignment: .top) {
                MapViewRepresentable()
                VStack {
                    UpperMapViewButtons()
                    Spacer()
                    LowerMapViewButtons()
                }
            }
            .navigationTitle("Reports")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        reportModel.isShowingLicensePlateScannerView.toggle()
                    } label: {
                        Image(systemName: "viewfinder")
                            .foregroundColor(.white)
                            .font(.system(size: 15).weight(.bold))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        
                    } label: {
                        Image(systemName: "list.dash")
                            .foregroundColor(.white)
                            .font(.system(size: 15).weight(.bold))
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
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
    
    @State private var isShowingNewReportView = false
    
    @EnvironmentObject var mapModel: MapViewModel
    @EnvironmentObject var reportModel: ReportsViewModel
    
    var body: some View {
        HStack {
            Spacer()
            Button {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                isShowingNewReportView.toggle()
            } label: {
                Image(systemName: "highlighter")
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
        }
        .padding(.bottom)
        .sheet(isPresented: $isShowingNewReportView) {
            NewReportView()
        }
    }
}

struct Map_Previews: PreviewProvider {
    static var previews: some View {
        ReportsMapView(mapModel: MapViewModel())
            .environmentObject(ReportsViewModel())
            .environmentObject(MapViewModel())
    }
}
