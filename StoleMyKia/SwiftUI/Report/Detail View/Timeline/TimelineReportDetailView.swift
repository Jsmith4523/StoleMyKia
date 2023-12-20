//
//  TimelineReportDetailView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/16/23.
//

import SwiftUI

struct TimelineReportDetailView: View {
    
    @State private var isShowingReportDetailView = false
    @State private var isShowingImageView = false
    @State private var vehicleImage: UIImage?
    
    let report: Report
    
    @Environment (\.dismiss) var dismiss
    
    @EnvironmentObject var timelineVM: TimelineMapViewModel
    @EnvironmentObject var reportsVM: ReportsViewModel
    @EnvironmentObject var userVM: UserViewModel
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 20) {
                                HStack(alignment: .top) {
                                    if report.hasVehicleImage {
                                        imageView
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        reportLabelsView(report: report)
                                        Text(report.vehicleDetails)
                                            .font(.system(size: 19).weight(.heavy))
                                            .lineLimit(2)
                                        Text(report.timeSinceString())
                                            .font(.system(size: 15))
                                        Text(report.location.distanceFromUser)
                                            .font(.system(size: 15))
                                            .foregroundColor(.gray)
                                    }
                                }
                                VStack(alignment: .leading) {
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
                                                Text("VIN: \(report.vehicle.hiddenVinString)")
                                            }
                                        }
                                        .font(.system(size: 17).bold())
                                    }
                                    Text(report.distinguishableDetails)
                                        .font(.system(size: 16))
                                }
                            }
                            Spacer()
                        }
                    }
                    .padding()
                }
            }
            .multilineTextAlignment(.leading)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Close")
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        URL.getDirectionsToLocation(title: report.vehicle.appleMapsAnnotationTitle, coords: report.location.coordinates)
                    } label: {
                        Image(systemName: "arrow.turn.up.right")
                    }
                    Button {
                        isShowingReportDetailView.toggle()
                    } label: {
                        Image(systemName: "info.circle")
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $isShowingImageView) {
            VehicleImageView(vehicleImage: $vehicleImage)
        }
        .fullScreenCover(isPresented: $isShowingReportDetailView) {
            ReportDetailView(reportId: report.id, timelineMapViewMode: .dismissWhenSelected, deleteCompletion: onDelete)
                .environmentObject(reportsVM)
                .environmentObject(userVM)
        }
    }
    
    var imageView: some View {
        Image(uiImage: vehicleImage ?? .vehiclePlaceholder)
            .resizable()
            .scaledToFill()
            .frame(width: 100, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .redacted(reason: vehicleImage.isNil() ? .placeholder : [])
            .onAppear {
                getVehicleImage()
            }
            .onTapGesture {
                self.isShowingImageView.toggle()
            }
    }
    
    func getVehicleImage() {
        ImageCache.shared.getImage(report.imageURL) { image in
            DispatchQueue.main.async {
                self.vehicleImage = image
            }
        }
    }
    
    private func onDelete() {
        guard let reportId = timelineVM.reportId else {
            dismiss()
            return
        }
        
        Task {
            try? await timelineVM.getUpdatesForReport(reportId)
        }
        dismiss()
    }
}

struct TimelineReportDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineReportDetailView(report: [Report].testReports().first!)
    }
}
