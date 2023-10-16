//
//  TimelineReportDetailView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/16/23.
//

import SwiftUI

struct TimelineReportDetailView: View {
    
    @State private var isShowingImageView = false
    @State private var vehicleImage: UIImage?
    
    let report: Report
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 20) {
                            HStack(alignment: .top) {
                                if report.hasVehicleImage {
                                    imageView
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    reportTypeLabelStyle(report: report)
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
                                            Text("VIN: \(report.vehicle.vinString)")
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
            .multilineTextAlignment(.leading)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $isShowingImageView) {
            VehicleImageView(vehicleImage: $vehicleImage)
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
}

struct TimelineReportDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineReportDetailView(report: [Report].testReports().first!)
    }
}
