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
                        .frame(width: UIScreen.main.bounds.width,height: 250)
                        .clipped()
                }
                VStack {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(report.reportType.rawValue)
                                .padding(5)
                                .background(Color(uiColor: report.reportType.annotationColor).opacity(0.65))
                                .font(.system(size: 17).weight(.heavy))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            
                            Spacer()
                            Text(report.dt.date)
                        }
                        .font(.system(size: 19))
                        .foregroundColor(.gray)
                        Text(report.vehicleDetails)
                            .font(.system(size: 20).weight(.heavy))
                            .foregroundColor(Color(uiColor: .label))
                        HStack {
                            if let name = report.location.name {
                                Label(name, systemImage: "mappin.and.ellipse")
                                    .foregroundColor(Color(uiColor: .label))
                            }
                            if let address = report.location.address {
                                Divider()
                                    .frame(height: 15)
                                Text(address)
                                    .foregroundColor(.gray)
                            }
                        }
                        .font(.system(size: 17))
                        Spacer()
                            .frame(height: 5)
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

struct ReportCellVIew_Previews: PreviewProvider {
    static var previews: some View {
        ReportCellView(report: .init(dt: Date.now.epoch, reportType: .found, vehicle: .init(vehicleYear: 2011, vehicleMake: .hyundai, vehicleColor: .gold, vehicleModel: .elantra), distinguishable: "", imageURL: "https://automanager.blob.core.windows.net/wmphotos/012928/b98b458d9854eb4db5b9d4d637b5cbf5/b21f0c7166_800.jpg", location: .init(address: "1105 South Drive, Oxon Hill, Maryland",name: "92NY",lat: 0, lon: 0)))
            .environmentObject(ReportsViewModel())
            .environmentObject(UserViewModel())
    }
}
