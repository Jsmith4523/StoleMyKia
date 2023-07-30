//
//  SelectedReportDetailView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/10/23.
//

import SwiftUI
import MapKit

struct SelectedReportDetailView: View {
    
    ///Determines how the TimelineMapView will present itself when selected by the user
    enum TimelineMapViewMode {
        case dismissWhenSelected
        case presentWhenSelected
    }
    
    let report: Report
    var timelineMapViewMode: TimelineMapViewMode = .presentWhenSelected
    
    @State private var isShowingFalseReportView = false
    @State private var isShowingTimelineMapView = false
    @State private var isShowingUpdateReportView = false
    @State private var isShowingReportOptions = false
    
    @State private var vehicleImage: UIImage?
    
    @EnvironmentObject var reportsVM: ReportsViewModel
    @EnvironmentObject var userVM: UserViewModel
    
    @Environment (\.dismiss) var dismiss
        
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading) {
                            if report.hasVehicleImage {
                                vehicleImageView
                            } else {
                                SelectedReportDetailMapView(report: report)
                                    .frame(height: 215)
                                    .onTapGesture {
                                        presentTimelineMapView()
                                    }
                            }
                            VStack(spacing: 30) {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(report.reportType.rawValue)
                                            .padding(5)
                                            .background(Color(uiColor: report.reportType.annotationColor).opacity(0.65))
                                            .font(.system(size: 19).weight(.heavy))
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                        Spacer()
                                        Text(report.timeSinceString())
                                            .font(.system(size: 16))
                                            .foregroundColor(.gray)
                                    }
                                    VStack(alignment: .leading, spacing: 10) {
                                        VStack(alignment: .leading, spacing: 7) {
                                            Text(report.vehicleDetails)
                                                .font(.system(size: 25).weight(.heavy))
                                            VStack(alignment: .leading) {
                                                if report.hasLicensePlate {
                                                    Text(report.vehicle.licensePlateString)
                                                }
                                                if report.location.hasName {
                                                    VStack(alignment: .leading) {
                                                        Text(report.location.name ?? "")
                                                        Text(report.location.address ?? "")
                                                            .foregroundColor(.gray)
                                                    }
                                                }
                                            }
                                            .font(.system(size: 17))
                                        }
                                        Text(report.distinguishableDetails)
                                            .font(.system(size: 16))
                                            .lineSpacing(2)
                                    }
                                }
                                if report.hasVehicleImage {
                                    SelectedReportDetailMapView(report: report)
                                        .frame(height: 175)
                                        .cornerRadius(20)
                                        .onTapGesture {
                                            presentTimelineMapView()
                                        }
                                }
                            }
                            .padding()
                        }
                    }
                    Spacer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        
                    } label: {
                        Image(systemName: "arrow.2.squarepath")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingReportOptions.toggle()
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
            }
            .tint(Color(uiColor: .label))
            .confirmationDialog("Options", isPresented: $isShowingReportOptions) {
                Button("Directions") {
                    URL.getDirectionsToLocation(coords: report.location.coordinates)
                }
                Button("Bookmark") {
                    
                }
                if let uid = userVM.uid {
                    if report.uid == uid {
                        Button("Delete", role: .destructive) {
                            
                        }
                    } else {
                        Button("False Report") {
                            self.isShowingFalseReportView.toggle()
                        }
                    }
                }
            }
            .sheet(isPresented: $isShowingTimelineMapView) {
                TimelineMapView(report: report)
                    .environmentObject(reportsVM)
            }
            .fullScreenCover(isPresented: $isShowingFalseReportView) {
                FalseReportView(report: report)
                    .environmentObject(userVM)
            }
        }
        .onAppear {
            getVehicleImage()
        }
    }
    
    private func presentTimelineMapView() {
        //Prevents allocating a new MKMapView in cases if this detail view
        //Is presented within the TimelineMapView
        switch timelineMapViewMode {
        case .dismissWhenSelected:
            dismiss()
        case .presentWhenSelected:
            self.isShowingTimelineMapView.toggle()
        }
    }
    
    private var vehicleImageView: some View {
        Image(uiImage: vehicleImage ?? .vehiclePlaceholder)
            .resizable()
            .scaledToFill()
            .frame(height: 300)
            .clipped()
    }
    
    private func getVehicleImage() {
        ImageCache.shared.getImage(report.imageURL) { image in
            self.vehicleImage = image
        }
    }
}

struct SelectedReportDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SelectedReportDetailView(report: [Report].testReports().first!)
            .environmentObject(ReportsViewModel())
            .environmentObject(UserViewModel())
    }
}
