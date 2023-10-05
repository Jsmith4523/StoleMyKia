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
            ZStack {
                LazyVStack {
                    ForEach(timelimeMapViewCoordinator.reports.sorted(by: >)) { report in
                        TimelineListCellView(report: report)
                            .onTapGesture {
                                if (report.isFalseReport || report.discloseLocation) {
                                    timelimeMapViewCoordinator.mapViewSheetMode = .report(report)
                                } else {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        timelimeMapViewCoordinator.didSelectReport(report)
                                    }
                                }
                            }
                        Divider()
                            .padding()
                    }
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
        ZStack(alignment: .leading) {
            HStack(alignment: .top) {
                Spacer()
                    .frame(width: 5.5)
                reportTypeIcon
                VStack(alignment: .leading) {
                    Text(report.reportType.rawValue)
                        .font(.system(size: 15).weight(.heavy))
                    reportDescription
                        .lineLimit(3)
                }
                Spacer()
                if report.hasVehicleImage {
                    vehicleImageView
                }
            }
            .padding()
        }
        .multilineTextAlignment(.leading)
    }
    
    private var reportDescription: some View {
        VStack(alignment: .leading) {
            Text(report.timeSinceString())
                .font(.system(size: 13).weight(.medium))
            Text(report.distinguishableDetails)
                .font(.system(size: 12.5))
        }
    }
    
    private var reportTypeIcon: some View {
        VStack {
            Image(systemName: report.reportType.annotationImage)
                .resizable()
                .scaledToFit()
                .frame(width: 15, height: 15)
                .padding(7)
                .foregroundColor(.white)
                .background(Color(uiColor: report.reportType.annotationColor))
                .clipShape(Circle())
            if !report.role.isAnUpdate {
                Image.updateImageIcon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 17, height: 17)
            }
            if report.discloseLocation {
                Image.disclosedLocationIcon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 17, height: 17)
                    .foregroundColor(.discloseLocationColor)
            }
            if report.isFalseReport {
                Image.falseReportIcon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 17, height: 17)
                    .foregroundColor(.falseReportColor)
            }
        }
    }
    
    private var vehicleImageView: some View {
        Image(uiImage: vehicleImage ?? .vehiclePlaceholder)
            .resizable()
            .scaledToFill()
            .frame(width: 85, height: 85)
            .clipShape(RoundedRectangle(cornerRadius: 2.75))
            .redacted(reason: vehicleImage.isNil() ? .placeholder : [])
            .onAppear {
                getVehicleImage()
            }
    }
    
    private func getVehicleImage() {
        ImageCache.shared.getImage(report.imageURL) { image in
            self.vehicleImage = image
        }
    }
}

fileprivate struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to:CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY+100))
        return path
    }
}

struct TimelineList_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            TimelineListCellView(report: [Report].testReports().first!)
        }
    }
}
