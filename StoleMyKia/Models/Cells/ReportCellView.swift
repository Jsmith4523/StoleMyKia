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
                            .font(.system(size: 20).weight(.heavy))
                        Spacer()
                    }
                    VStack(alignment: .leading, spacing: 5) {
                        Text(report.vehicleDetails)
                            .bold()
                        //TODO: Add license information
                        Label("1EP1757", systemImage: "character.textbox")
                            .font(.system(size: 13))
                        HStack {
                            Text(report.postDate)
                            Divider()
                                .frame(height: 15)
                            Text(report.postTime)
                        }
                        .font(.system(size: 15.5))
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
                        .shadow(color: .brand, radius: 0.5)
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

