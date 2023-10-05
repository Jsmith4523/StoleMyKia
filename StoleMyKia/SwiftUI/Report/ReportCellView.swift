//
//  ReportCellVIew.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/10/23.
//

import SwiftUI

struct ReportCellView: View {
    
    @State private var isBookmarked: Bool = false
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
                        .frame(width: UIScreen.main.bounds.width)
                        .frame(height: 300)
                        .clipped()
                        .redacted(reason: vehicleImage == nil ? .placeholder : [])
                        .onAppear {
                            getVehicleImage()
                        }
                }
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        VStack(alignment: .leading, spacing: 11) {
                            HStack {
                                reportTypeLabelStyle(report: report)
                                Spacer()
                            }
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            VStack(alignment: .leading, spacing: 8) {
                                Text(report.vehicleDetails)
                                    .font(.system(size: 20).weight(.heavy))
                                    .foregroundColor(Color(uiColor: .label))
                                    .lineLimit(1)
                                if (report.hasVin || report.hasLicensePlate) {
                                    HStack {
                                        if report.hasLicensePlate {
                                            Text(report.vehicle.licensePlateString)
                                        }
                                        if (report.hasLicensePlate && report.hasVin) {
                                            Divider()
                                                .frame(height: 10)
                                        }
                                        if report.hasVin {
                                            if let formattedVin = ApplicationFormats.vinFormat(report.vehicle.vinString) {
                                            Text("VIN: \(formattedVin)")
                                            }
                                        }
                                    }
                                    .font(.system(size: 15))
                                }
                                Text(report.distinguishableDetails)
                                    .font(.system(size: 15))
                                    .lineLimit(3)
                            }
                        }
                        HStack {
                            Text(report.timeSinceString())
                            if !(report.location.distanceFromUser == "") {
                                Divider()
                                    .frame(height: 10)
                                Text(report.location.distanceFromUser)
                            }
                            Spacer()
                        }
                        .foregroundColor(.gray)
                        .font(.system(size: 15))
                    }
                }
                .padding()
            }
        }
        .background(Color(uiColor: .systemBackground))
        .multilineTextAlignment(.leading)
    }
    
    private func setBookmark() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        Task {
            if isBookmarked {
                self.isBookmarked = false
                try! await FirebaseUserManager.undoBookmark(report.id)
            } else {
                do {
                    self.isBookmarked = true
                    try await FirebaseUserManager.bookmarkReport(report.id)
                } catch {
                    self.isBookmarked = false
                }
            }
        }
    }
    
    private func getVehicleImage() {
        guard let imageUrl = report.imageURL else {
            return
        }
        
        ImageCache.shared.getImage(imageUrl) { image in
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
                Image.falseReportIcon
                    
            } else if report.role.isAnUpdate {
                Image.updateImageIcon
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
