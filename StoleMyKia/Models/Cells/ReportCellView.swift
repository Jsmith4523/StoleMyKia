//
//  ReportCellView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 5/28/23.
//

import Foundation
import SwiftUI

struct ReportCellView: View {
    
    @State private var vehicleImage: UIImage?
    
    let report: Report
    
    @EnvironmentObject var reportsModel: ReportsViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    HStack {
                        Text(report.type)
                            .font(.system(size: 22).weight(.heavy))
                        Spacer()
                    }
                    VStack(alignment: .leading) {
                        Text(report.vehicleDetails)
                        Text(report.postDate)
                    }
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                }
                Spacer()
                if report.hasVehicleImage {
                    Image(uiImage: vehicleImage ?? .vehiclePlaceholder)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 75, height: 75)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
            }
        }
        .padding()
        .onAppear {
            getVehicleImage()
        }
    }
    
    private func getVehicleImage() {
        ImageCache.shared.getImage(report.imageURL) { image in
            withAnimation {
                self.vehicleImage = image
            }
        }
    }
}

struct MyPreviewProvider5_Previews: PreviewProvider {
    static var previews: some View {
        ReportCellView(report: .init(dt: Date.now.epoch, reportType: .stolen, vehicle: .init(vehicleYear: 2018, vehicleMake: .hyundai, vehicleColor: .black, vehicleModel: .elantra), licensePlate: nil, vin: nil, distinguishable: "", location: .none))
    }
}
