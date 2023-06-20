//
//  SelectedReportDetailView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/10/23.
//

import SwiftUI
import MapKit

struct SelectedReportDetailView: View {
    
    let reportID: UUID
    
    @State private var isShowingErrorView = false
    @State private var errorReason: FetchReportError = .unavaliable
    
    @State private var report: Report?
        
    @State private var vehicleImage: UIImage?
    
    @EnvironmentObject var reportsModel: ReportsViewModel
    @EnvironmentObject var userModel: UserViewModel
    
    @Environment (\.dismiss) var dismiss
        
    var body: some View {
        ZStack {
            if let report {
                ScrollView {
                    VStack(alignment: .leading) {
                        ZStack {
                            TabView {
                                if report.hasVehicleImage {
                                    vehicleImageView
                                }
                                NavigationLink {
                                    TimelineMapView(report: report)
                                } label: {
                                    SelectedReportDetailViewMap(report: report)
                                }
                                //Child reports that have a parent do not need to utilize the timeline map view; as that child report cannot contain any updates of itself
                                //.disabled(report.hasParent)
                            }
                        }
                        .frame(height: 250)
                        .tabViewStyle(.page(indexDisplayMode: .automatic))
                        VStack(alignment: .leading) {
                            HStack {
                                Text(report.reportType.rawValue)
                                    .padding(5)
                                    .background(Color(uiColor: report.reportType.annotationColor).opacity(0.65))
                                    .font(.system(size: 17).weight(.heavy))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                Spacer()
                                HStack {
                                    Text(report.dt.date)
                                    Divider()
                                        .frame(height: 20)
                                    Text(report.dt.time)
                                }
                                .font(.system(size: 17))
                                .foregroundColor(.gray)
                            }
                            VStack(alignment: .leading, spacing: 10) {
                                Text(report.vehicleDetails)
                                    .font(.system(size: 24).weight(.heavy))
                                HStack {
                                    if let locationName = report.location.name {
                                        Label(locationName, systemImage: "mappin.and.ellipse")
                                    }
                                }
                                .font(.system(size: 17))
                            }
                        }
                        .padding()
                        Spacer()
                    }
                }
                .navigationTitle(report.reportType.rawValue)
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Menu {
                            Button {
                                
                            } label: {
                                Label("Concerned", systemImage: "questionmark")
                            }
                            Button {
                                
                            } label: {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                        }
                    }
                }
                .onAppear {
                    report.vehicleImage { image in
                        self.vehicleImage = image
                    }
                }
            } else {
                switch isShowingErrorView {
                case true:
                    ReportErrorView(fetchErrorReason: errorReason)
                case false:
                    ProgressView()
                }
            }
        }
        .onAppear {
            getReportDetails()
        }
    }
    
    private var vehicleImageView: some View {
        Image(uiImage: vehicleImage ?? .vehiclePlaceholder)
            .resizable()
            .scaledToFill()
            .frame(width: UIScreen.main.bounds.width, height: 250)
    }
    
    private func getReportDetails() {
        reportsModel.getReportDetails(reportID) { result in
            switch result {
            case .success(let report):
                self.isShowingErrorView = false
                self.report = report 
            case .failure(let error):
                self.isShowingErrorView = true
                self.errorReason = error
            }
        }
    }
}

//struct SelectedReportDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            SelectedReportDetailView(report: .init(dt: Date.now.epoch, reportType: .found, vehicle: .init(vehicleYear: 2017, vehicleMake: .hyundai, vehicleColor: .black, vehicleModel: .kona), distinguishable: "", imageURL: "https://s3.us-east-2.amazonaws.com/dealer-inspire-vps-vehicle-images/c447-110005591/KM8K62AB0PU009265/7e3811453af8f6f40c7dcffda76f07e3.jpg", location: .init(name: "Grand Central Station", lat: 40.75110, lon: -73.97838)))
//                .navigationBarTitleDisplayMode(.inline)
//        }
//    }
//}
