//
//  SelectedReportDetailView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/10/23.
//

import SwiftUI
import MapKit

struct SelectedReportDetailView: View {
    
    @State private var vehicleImage: UIImage?
    
    @EnvironmentObject var reportsModel: ReportsViewModel
    @EnvironmentObject var userModel: UserViewModel
    
    let report: Report
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                detailTabView
                VStack(alignment: .leading) {
                    HStack {
                        Text(report.reportType.rawValue)
                            .padding(10)
                            .font(.system(size: 17).bold())
                            .foregroundColor(.white)
                            .background(Color(uiColor: report.reportType.annotationColor).opacity(0.6))
                            .cornerRadius(20)
                        Spacer()
                        HStack {
                            Text(report.dt.date)
                            Divider()
                                .frame(height: 20)
                            Text(report.dt.time)
                        }
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                    }
                    VStack(alignment: .leading, spacing: 10) {
                        Text(report.vehicleDetails)
                            .font(.system(size: 24).weight(.heavy))
                        HStack {
                            if let locationName = report.location.name {
                                Label(locationName, systemImage: "mappin.and.ellipse")
                            }
                            if let locationAddress = report.location.address {
                                Divider()
                                    .frame(height: 15)
                                Text(locationAddress)
                                    .foregroundColor(.gray)
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
            ToolbarItem(placement: .principal) {
                VStack {
                    Text(report.reportType.rawValue)
                        .font(.system(size: 18).bold())
                    Text(report.vehicleDetails)
                        .font(.system(size: 13))
                }
            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    
                } label: {
                    Image(systemName: "flag")
                }
            }
        }
        .onAppear {
            report.vehicleImage { image in
                self.vehicleImage = image
            }
        }
    }
    
    private var detailTabView: some View {
        ZStack {
            TabView {
                if report.hasVehicleImage {
                    vehicleImageView
                }
                NavigationLink {
                    
                } label: {
                    SelectedReportDetailViewMap(report: report)
                }
            }
        }
        .frame(height: 250)
        .tabViewStyle(.page(indexDisplayMode: .automatic))
    }
    
    private var vehicleImageView: some View {
        Image(uiImage: vehicleImage ?? .vehiclePlaceholder)
            .resizable()
            .scaledToFill()
            .frame(width: UIScreen.main.bounds.width, height: 250)
    }
}

struct SelectedReportDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SelectedReportDetailView(report: .init(dt: Date.now.epoch, reportType: .found, vehicle: .init(vehicleYear: 2017, vehicleMake: .hyundai, vehicleColor: .black, vehicleModel: .kona), distinguishable: "", imageURL: "https://s3.us-east-2.amazonaws.com/dealer-inspire-vps-vehicle-images/c447-110005591/KM8K62AB0PU009265/7e3811453af8f6f40c7dcffda76f07e3.jpg", location: .init(name: "Grand Central Station", lat: 40.75110, lon: -73.97838)))
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
