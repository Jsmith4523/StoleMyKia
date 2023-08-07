//
//  ReportCellVIew.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/10/23.
//

import SwiftUI

struct ReportCellView: View {
    
    @State private var presentAlertFalseReport = false
        
    @State private var vehicleImage: UIImage?
    
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var reportsVM: ReportsViewModel
    
    let report: Report
    
    var body: some View {
        VStack {
            VStack(spacing: 0) {
                if report.hasVehicleImage {
                    Image(uiImage: vehicleImage ?? .vehiclePlaceholder)
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width, height: 300)
                        .clipped()
                        .redacted(reason: vehicleImage == nil ? .placeholder : [])
                }
                VStack(alignment: .leading, spacing: 20) {
                    VStack {
                        VStack(alignment: .leading, spacing: 11) {
                            HStack {
                                reportTypeLabelStyle(report: report)
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text(report.timeSinceString())
                                }
                            }
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            VStack(alignment: .leading, spacing: 5) {
                                Text(report.vehicleDetails)
                                    .font(.system(size: 20).weight(.heavy))
                                    .foregroundColor(Color(uiColor: .label))
                                    .lineLimit(2)
                                    //.lineLimit(2)
                                if let locationName = report.location.name {
                                    Text(locationName)
                                        .font(.system(size: 17))
                                        .foregroundColor(.gray)
                                }
                                Text(report.distinguishableDetails)
                                    .font(.system(size: 15))
                                    .lineLimit(3)
                            }
                        }
                    }
                    
                    HStack {
                        Button {
                            
                        } label: {
                            Image(systemName: "bookmark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.gray)
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
        .alert("False!", isPresented: $presentAlertFalseReport) {
            Button("OK") {}
        } message: {
            Text(report.role.falseReportDescription)
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

extension View  {
    
    func reportTypeLabelStyle(report: Report) -> some View {
        HStack {
            if report.isFalseReport {
                Image(systemName: "exclamationmark.shield")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
            } else if report.role.isAnUpdate {
                Image(systemName: "arrow.2.squarepath")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
            }
            Text(report.reportType.rawValue)
        }
        .padding(5)
        .background(Color(uiColor: report.reportType.annotationColor).opacity(0.72))
        .font(.system(size: 16).weight(.heavy))
        .foregroundColor(.white)
        .cornerRadius(10)
    }
}

struct ReportCellView_Previews: PreviewProvider {
    static var previews: some View {
        ReportCellView(report: [Report].testReports().first!)
            .environmentObject(ReportsViewModel())
            .environmentObject(UserViewModel())
    }
}
