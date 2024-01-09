//
//  UserReportsListView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/20/23.
//

import SwiftUI

struct UserReportsListView: View {
    
    @State private var report: Report?
    
    let reports: [Report]
    
    var deleteCompletion: (()->())? = nil
    
    @EnvironmentObject var reportsVM: ReportsViewModel
    @EnvironmentObject var userVM: UserViewModel
    
    var body: some View {
        LazyVStack {
            ForEach(reports.sorted(by: >)) { report in
                ReportCellView(report: report, imageMode: .thumbnail)
                    .onTapGesture {
                        self.report = report
                    }
                Divider()
            }
        }
        .fullScreenCover(item: $report) { report in
            ReportDetailView(reportId: report.id, deleteCompletion: deleteCompletion)
                .environmentObject(reportsVM)
                .environmentObject(userVM)
        }
    }
}

struct ReportThumbnailCellView: View {
    
    @State private var updateQuantity: Int?
    @State private var vehicleImage: UIImage?
    
    let report: Report
    
    @EnvironmentObject var reportsVM: ReportsViewModel
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                ReportLabelView(report: report)
                VStack(alignment: .leading, spacing: 5) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(report.vehicleDetails)
                            .font(.system(size: 19).weight(.heavy))
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
                        Text("\(report.postDate) - \(report.postTime)")
                            .font(.system(size: 15.75))
                            .foregroundColor(.gray)
                    }
                    HStack(spacing: 4) {
                        Image.updateImageIcon
                            .resizable()
                            .scaledToFit()
                            .frame(width: 15, height: 15)
                        Text("\(updateQuantity ?? 0)")
                    }
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                }
            }
            Spacer()
            if report.hasVehicleImage {
                imageView
            }
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .task {
            await getUpdateQuantity()
        }
    }
    
    private var imageView: some View {
        Image(uiImage: vehicleImage ?? .vehiclePlaceholder)
            .resizable()
            .scaledToFill()
            .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
            .redacted(reason: vehicleImage.isNil() ? .placeholder : [])
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .onAppear {
                getVehicleImage()
            }
    }
    
    private func getVehicleImage() {
        ImageCache.shared.getImage(report.imageURL) { image in
            self.vehicleImage = image
        }
    }
    
    private func getUpdateQuantity() async {
        let quantity = await ReportManager.manager.getNumberOfUpdates(report)
        self.updateQuantity = quantity
    }
}

#Preview {
    ReportThumbnailCellView(report: [Report].testReports().first!)
        .environmentObject(ReportsViewModel())
}
