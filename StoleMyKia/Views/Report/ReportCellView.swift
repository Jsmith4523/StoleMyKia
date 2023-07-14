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
                        .scaledToFit()
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
                            VStack(alignment: .trailing) {
                                Text(report.dt.full)
                            }
                        }
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        VStack(alignment: .leading, spacing: 5) {
                            Text(report.vehicleDetails)
                                .font(.system(size: 20).weight(.heavy))
                                .foregroundColor(Color(uiColor: .label))
                                .lineLimit(2)
                            if let locationName = report.location.name {
                                Text(locationName)
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray)
                            }
                            Text(report.distinguishableDetails)
                                .font(.system(size: 15))
                                .lineLimit(3)
                        }
                        HStack {
                            Button {
                                
                            } label: {
                                Image(systemName: "bookmark")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 18, height: 18)
                                    .foregroundColor(.gray)
                            }
                        }
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

struct ReportCellView_Previews: PreviewProvider {
    static var previews: some View {
        ReportCellView(report: [Report].testReports()[1])
            .environmentObject(ReportsViewModel())
            .environmentObject(UserViewModel())
    }
}
