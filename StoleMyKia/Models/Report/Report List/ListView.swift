//
//  ListView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 4/9/23.
//

import Foundation
import MapKit
import SwiftUI

struct ListView: View {
    
    @Binding var reports: [Report]
    
    var imageCache: ImageCache = ImageCache()
    
    @EnvironmentObject var reportsModel: ReportsViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(reports) { report in
                    ReportListCellView(report: report, imageCache: imageCache)
                    Divider()
                        .padding(.horizontal)
                }
            }
        }
    }
}


fileprivate struct ReportListCellView: View {
    
    @State private var isShowingReportDetailView = false
    
    @State private var vehicleImage: UIImage?
    
    let report: Report
    let imageCache: ImageCache
    
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
                ZStack {
                    if !(report.imageURL == nil) {
                        if let vehicleImage {
                            Image(uiImage: vehicleImage)
                                .resizable()
                                .scaledToFill()
                            
                        } else {
                            ProgressView()
                        }
                    } else {
                        ReportMap(report: report)
                    }
                }
                .frame(width: 75, height: 75)
                .cornerRadius(10)
            }
        }
        .padding()
        .onAppear {
            getVehicleImage()
        }
        .onTapGesture {
            self.isShowingReportDetailView.toggle()
        }
        .reportDetailView(isPresented: $isShowingReportDetailView, cache: imageCache, report: report)
    }
    
    private func getVehicleImage() {
        imageCache.getImage(report.imageURL) { image in
            withAnimation {
                self.vehicleImage = image
            }
        }
    }
}
