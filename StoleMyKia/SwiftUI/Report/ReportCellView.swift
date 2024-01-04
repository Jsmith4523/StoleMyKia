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
    var imageMode: CellViewImageMode = .large
    
    @Environment (\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            VStack(spacing: 0) {
                if (report.hasVehicleImage && imageMode == .large) {
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
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 10) {
                            VStack(alignment: .leading, spacing: 11) {
                                ReportLabelView(report: report)
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(report.vehicleDetails)
                                        .font(.system(size: 20).weight(.heavy))
                                        .foregroundColor(Color(uiColor: .label))
                                        .lineLimit(imageMode == .thumbnail ? 2 : 1)
                                    if (report.hasVin || report.hasLicensePlate) {
                                        HStack {
                                            if report.hasLicensePlate {
                                                Text(report.vehicle.licensePlateString)
                                            }
                                            if report.hasLicensePlateAndVin {
                                                Divider()
                                                    .frame(height: 10)
                                            }
                                            if report.hasVin {
                                                Text("VIN: \(report.vehicle.hiddenVinString)")
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
                    if (report.hasVehicleImage && imageMode == .thumbnail) {
                        HStack {
                            Spacer()
                                .frame(width: 15)
                            Image(uiImage: vehicleImage ?? .vehiclePlaceholder)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .redacted(reason: vehicleImage == nil ? .placeholder : [])
                                .onAppear {
                                    getVehicleImage()
                                }
                        }
                    }
                }
                .padding()
            }
        }
        .background(colorScheme == .dark ? .black : .white)
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

struct ReportLabelView: View {
    
    let report: Report
    
    var body: some View {
        HStack(spacing: 4) {
            reportTypeLabelStyle(report: report)
            if report.hasBeenResolved {
                reportResolvedLabel()
            }
            if report.discloseLocation {
                reportDiscloseLocationLabel()
            }
            if report.belongsToUser {
                reportCurrentUserLabel()
            }
        }
    }
}

extension View  {
    
    func reportLabelsView(report: Report) -> some View {
        HStack(spacing: 4) {
            reportTypeLabelStyle(report: report)
            if report.hasBeenResolved {
                reportResolvedLabel()
            }
            if report.discloseLocation {
                reportDiscloseLocationLabel()
            }
            if report.belongsToUser {
                reportCurrentUserLabel()
            }
            Spacer()
        }
        .font(.system(size: 14))
        .foregroundColor(.gray)
    }
    
    @ViewBuilder
    func reportTypeLabelStyle(report: Report) -> some View {
        HStack(spacing: 4) {
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
    
    @ViewBuilder
    func reportResolvedLabel() -> some View {
        Image(systemName: "checkmark.seal.fill")
            .reportLabelStyle(backgroundColor: .green)
    }
    
    @ViewBuilder
    func reportCurrentUserLabel() -> some View {
        Image(systemName: "person.crop.circle.fill")
            .reportLabelStyle(backgroundColor: .gray)
    }
    
    @ViewBuilder
    func reportDiscloseLocationLabel() -> some View {
        Image(systemName: "mappin.slash.circle")
            .reportLabelStyle(backgroundColor: .blue)
    }
}

private extension Image {
    
    func reportLabelStyle(backgroundColor: Color) -> some View {
        return self
            .resizable()
            .scaledToFit()
            .frame(width: 20, height: 20)
            .padding(4)
            .foregroundColor(.white)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .fontWeight(.bold)
    }
}

struct ReportCellView_Previews: PreviewProvider {
    static var previews: some View {
        ReportCellView(report: [Report].testReports().first!, imageMode: .thumbnail)
            .environmentObject(ReportsViewModel())
            .environmentObject(UserViewModel())
    }
}
