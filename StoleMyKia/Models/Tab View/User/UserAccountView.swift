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

