//
//  ReportCellVIew.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/10/23.
//

import SwiftUI

struct ReportCellView: View {
        
    @State private var vehicleImage: UIImage?
    
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var reportsVM: ReportsViewModel
    
    let report: Report
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(spacing: 0) {
                if report.hasVehicleImage {
                    Image(uiImage: vehicleImage ?? .vehiclePlaceholder)
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width,height: 225)
                        .clipped()
                }
                VStack {
                    VStack(alignment: .leading, spacing: 11) {
                        HStack {
                            Text(report.reportType.rawValue)
                                .padding(5)
                                .background(Color(uiColor: report.reportType.annotationColor).opacity(0.65))
                                .font(.system(size: 16).weight(.heavy))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            
                            Spacer()
                            Text(report.dt.date)
                                .font(.system(size: 17))
                        }
                        .font(.system(size: 19))
                        .foregroundColor(.gray)
                        Text(report.vehicleDetails)
                            .font(.system(size: 20).weight(.heavy))
                            .foregroundColor(Color(uiColor: .label))
                            .lineLimit(2)
                        HStack {
                            if !(report.vehicle.licensePlateString.isEmpty) {
                                Label(report.vehicle.licensePlateString, systemImage: "light.panel")
                            }
                            if let name = report.location.name {
                                Label(name, systemImage: "mappin.and.ellipse")
                                    .foregroundColor(Color(uiColor: .label))
                            }
                            Spacer()
                            HStack(spacing: 13) {
                                Button {
                                    
                                } label: {
                                   Image(systemName: "square.and.arrow.up")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 25, height: 25)
                                }
                                Button {
                                    
                                } label: {
                                    Image(systemName: "bookmark")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 25, height: 25)
                                }
                            }
                            .foregroundColor(Color(uiColor: .label))
                        }
                        .font(.system(size: 17))
                        Spacer()
                            .frame(height: 5)
                    }
                }
                .padding()
            }
        }
        .background(Color(uiColor: .systemBackground))
        .multilineTextAlignment(.leading)
        .onAppear {
            getVehicleImage()
        }
    }
    
    
    private func getVehicleImage() {
        ImageCache.shared.getImage(report.imageURL) { image in
            guard let image else {
                return
            }
            
            self.vehicleImage = image
        }
    }
}
