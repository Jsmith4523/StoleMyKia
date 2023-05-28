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
                ZStack(alignment: .bottomTrailing) {
                    MapViewRep()
                        .edgesIgnoringSafeArea(.top)
                    MapButtons()
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        reportModel.isShowingLicensePlateScannerView.toggle()
                    } label: {
                        Image(systemName: "camera")
                            .foregroundColor(.white)
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

fileprivate struct MapHeader: View {
    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(colors: [.black.opacity(0.65), .clear], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
                .frame(height: 100)
            HStack {
                Text("Reports")
                    .font(.system(size: 35).weight(.heavy))
                Spacer()
                HStack {
                    Button {
                        
                    } label: {
                        Image(systemName: "text.justify")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .padding(11)
                            .background(Color.accentColor)
                            .clipShape(Circle())
                    }

                }
            }
            .padding()
            .foregroundColor(.white)
        }
    }
}

fileprivate struct MapButtons: View {
    
    @EnvironmentObject var mapModel: MapViewModel
    @EnvironmentObject var reportModel: ReportsViewModel
    
    var body: some View {
        HStack {
//            Button {
//                
//            } label: {
//                Image(systemName: "")
//            }
            Spacer()
            Button {
                reportModel.isShowingNewReportView.toggle()
            } label: {
               Label("New Report", systemImage: "pencil")
                    .padding()
                    .font(.system(size: 20).weight(.bold))
                    .foregroundColor(.white)
                    .background(Color.accentColor)
                    .cornerRadius(30)
                    .shadow(radius: 4)
            }
            
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
        .padding(.bottom, 45)
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
        ReportsMapView()
            .environmentObject(ReportsViewModel())
            .environmentObject(MapViewModel())
    }
}
