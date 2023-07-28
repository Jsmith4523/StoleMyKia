//
//  TimelineListView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 7/21/23.
//

import SwiftUI

struct TimelineListView: View {
    
    @EnvironmentObject var timelimeMapViewCoordinator: TimelineMapViewCoordinator
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                switch timelimeMapViewCoordinator.isLoading {
                case true:
                    ProgressView()
                case false:
                    switch timelimeMapViewCoordinator.reports.isEmpty {
                    case true:
                        noUpdates
                    case false:
                        list
                    }
                }
            }
            .navigationTitle("List")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    
    private var noUpdates: some View {
        VStack {
            Spacer()
                .frame(height: 130)
            Text("Sorry, no updates have been made yet!")
                .font(.system(size: 17))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private var list: some View {
        ScrollView {
            VStack {
                ForEach(timelimeMapViewCoordinator.reports.sorted(by: >)) { report in
                    Button {
                        setMapRegionToReportLocation(location: report.location)
                    } label: {
                        TimelineListCellView(report: report)
                    }
                    Divider()
                }
            }
        }
    }
    
    private func setMapRegionToReportLocation(location: Location) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        dismiss()
        timelimeMapViewCoordinator.setRegionToReport(location: location)
    }
}

fileprivate struct TimelineListCellView: View {
    
    @State private var vehicleImage: UIImage?
    
    let report: Report
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(report.reportType.rawValue)
                    .foregroundColor(.white)
                    .font(.system(size: 16).bold())
                    .padding(3)
                    .background(Color(uiColor: report.reportType.annotationColor).opacity(0.65))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                Spacer()
                Text(report.timeSinceString())
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            HStack {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            if let locationName = report.location.name, let address = report.location.address {
                                Text("\(locationName) - \(address)")
                                    .font(.system(size: 13))
                            }
                            Spacer()
                        }
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        Text(report.distinguishableDetails)
                            .font(.system(size: 15))
                            .lineLimit(3)
                    }
                }
                Spacer()
                if report.hasVehicleImage {
                    Image(uiImage: vehicleImage ?? .vehiclePlaceholder)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 85, height: 85)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            HStack(spacing: 13) {
                Button {
                    getDirectionsForReport()
                } label: {
                    Image(systemName: "arrow.triangle.turn.up.right.diamond")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                }
            }
            .foregroundColor(Color(uiColor: .label))
        }
        .padding()
        .multilineTextAlignment(.leading)
        .onAppear {
            getVehicleImage()
        }
    }
    
    private func getVehicleImage() {
        ImageCache.shared.getImage(report.imageURL) { image in
            self.vehicleImage = image
        }
    }
    
    private func getDirectionsForReport() {
        URL.getDirectionsToLocation(coords: report.location.coordinates)
    }
}

//#Preview {
//    TimelineListCellView(report: [Report].testReports().first!)
//}
