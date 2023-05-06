//
//  UserReportsView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 5/5/23.
//

import Foundation
import SwiftUI

struct UserReportsView: View {
        
    @State private var isLoading = false
    @State private var didFailToFetchReports = false
    
    @State private var userReports = [Report]()
    
    @ObservedObject var userModel: UserViewModel
    
    let imageCache: ImageCache
    
    var body: some View {
        ZStack {
            switch isLoading {
            case true:
                ProgressView()
            case false:
                list
            }
        }
        .frame(maxHeight: .infinity)
        .onAppear {
            if userReports.isEmpty {
                fetchUserReports()
            }
        }
        .refreshable {
            fetchUserReports()
        }
    }
    
    var list: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                ForEach(userReports) { report in
                    UserReportCellView(report: report, imageCache: imageCache) {
                        fetchUserReports()
                    }
                }
                Spacer()
            }
        }
    }
    
    public func fetchUserReports() {
        if userReports.isEmpty {
            self.isLoading = true
        }
        
        userModel.getUserReports { results in
            switch results {
            case .success(let reports):
                self.userReports = reports
                self.isLoading = false
            case .failure(_):
                break
            }
        }
    }
    
    fileprivate struct UserReportCellView: View {
        
        @State private var isShowingReportDetailView = false
        
        @State private var vehicleImage: UIImage?
        
        let report: Report
        let imageCache: ImageCache
        
        var completion: (()->Void)?
        
        @EnvironmentObject var reportsModel: ReportsViewModel
        
        var body: some View {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(report.type)
                                .font(.system(size: 30).weight(.heavy))
                            Text(report.vehicleDetails)
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        report.status.label
                    }
                    .padding()
                    imageMap
                    Spacer()
                        .frame(height: 20)
                }
            }
            .onTapGesture {
                self.isShowingReportDetailView.toggle()
            }
            .sheet(isPresented: $isShowingReportDetailView) {
                SelectedReportDetailView(report: report, imageCache: imageCache) {
                    fetchUserReports()
                }
            }
            .onAppear {
                getVehicleImage()
            }
        }
        
        var imageMap: some View {
            ZStack {
                if !(report.imageURL == nil) {
                    Image(uiImage: vehicleImage ?? .vehiclePlaceholder)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipped()
                } else {
                    ReportDetailViewMap(report: report)
                        .frame(height: 175)
                }
            }
        }
        
        private func getVehicleImage() {
            if let imageUrl = report.imageURL {
                imageCache.getImage(imageUrl) { image in
                    guard let image else {
                        return
                    }
                    
                    self.vehicleImage = image
                }
            }
        }
        
        private func fetchUserReports() {
            guard let completion else {
                return
            }
            
            completion()
        }
    }
}
