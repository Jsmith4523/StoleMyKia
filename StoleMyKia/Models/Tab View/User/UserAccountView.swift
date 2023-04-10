//
//  UserAccountView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/27/23.
//

import SwiftUI
import MapKit

struct UserAccountView: View {
    
    @State private var userReports: [Report]?
    
    @State private var isShowingSettingsView = false
    
    @ObservedObject var loginModel: LoginViewModel
    
    @EnvironmentObject var notificationModel: NotificationViewModel
    @EnvironmentObject var reportsModel: ReportsViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack {
                        if let userReports {
                            ForEach(userReports) { report in
                                UserReportCellView(report: report)
                            }
                        }
                    }
                }
            }
            .refreshable {
                self.fetchUserReports()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingSettingsView.toggle()
                    } label: {
                       Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $isShowingSettingsView) {
                SettingsView()
                    .interactiveDismissDisabled()
            }
            .onAppear {
                if userReports == nil {
                    self.fetchUserReports()
                }
            }
            .environmentObject(notificationModel)
            .environmentObject(loginModel)
            .environmentObject(reportsModel)
        }
    }
    
    private func fetchUserReports() {
        reportsModel.getUsersReports { reports in
            guard let reports else {
                return
            }
            self.userReports = reports
        }
    }
}

fileprivate struct UserReportCellView: View {
    
    @State private var vehicleImage: UIImage?
    
    let report: Report
    
    @EnvironmentObject var reports: ReportsViewModel
    
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
                    Button {
                        
                    } label: {
                        Image(systemName: "ellipsis")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    }
                }
                .padding()
                ZStack {
                    ReportMap(report: report)
                        .frame(height: 175)
                    
                }
                Spacer()
                    .frame(height: 20)
            }
        }
    }
}

struct UserAccountView_Previews: PreviewProvider {
    static var previews: some View {
        UserReportCellView(report: .init(dt: Date.now.epoch, reportType: .stolen, vehicleYear: 2012, vehicleMake: .hyundai, vehicleColor: .white, vehicleModel: .elantra, licensePlate: nil, vin: nil, imageURL: "data:image/jpeg;base64,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", lat: 38.87648, lon: -76.97732))
            .environmentObject(ReportsViewModel())
            .environmentObject(NotificationViewModel())
    }
}
