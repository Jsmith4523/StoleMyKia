//
//  SelectedReportDetailView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/10/23.
//

import SwiftUI
import MapKit

struct SelectedReportDetailView: View {
    
    let report: Report
    
    @State private var isShowingTimelineMapView = false
    @State private var isShowingUpdateReportView = false
    
    @State private var vehicleImage: UIImage?
    
    @EnvironmentObject var reportsVM: ReportsViewModel
    @EnvironmentObject var userModel: UserViewModel
    
    @Environment (\.dismiss) var dismiss
        
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading) {
                            vehicleImageView
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
                                        Text("\(report.postDate) - \(report.postTime)")
                                            .font(.system(size: 16))
                                            .foregroundColor(.gray)
                                    }
                                    VStack(alignment: .leading, spacing: 10) {
                                        VStack(alignment: .leading, spacing: 7) {
                                            Text(report.vehicleDetails)
                                                .font(.system(size: 25).weight(.bold))
                                            VStack(alignment: .leading) {
                                                Text(report.vehicle.licensePlateString)
                                                    .font(.system(size: 20).weight(.heavy))
                                                if report.location.hasName {
                                                    VStack(alignment: .leading) {
                                                        Text(report.location.name ?? "")
                                                        Text(report.location.address ?? "")
                                                    }
                                                }
                                            }
                                            .font(.system(size: 17))
                                            .foregroundColor(.gray)
                                        }
                                        Text(report.distinguishableDetails)
                                            .font(.system(size: 16))
                                            .lineSpacing(2)
                                    }
                                }
                                SelectedReportDetailMapView(report: report)
                                    .frame(height: 175)
                                    .cornerRadius(20)
                                    .onTapGesture {
                                        self.isShowingTimelineMapView.toggle()
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
                        Image(systemName: "arrow.triangle.swap")
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
            }
            .tint(Color(uiColor: .label))
            .sheet(isPresented: $isShowingTimelineMapView) {
                TimelineMapView(report: report)
                    .presentationDragIndicator(.visible)
                    .environmentObject(reportsVM)
            }
        }
        .onAppear {
            getVehicleImage()
        }
    }
    
    private var vehicleImageView: some View {
        Image(uiImage: vehicleImage ?? .vehiclePlaceholder)
            .resizable()
            .scaledToFill()
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
    }
}
