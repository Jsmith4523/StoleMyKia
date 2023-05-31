//
//  UserReportsView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 5/28/23.
//

import Foundation
import SwiftUI

struct UserReportsView: View {
        
    @State private var userReports = [Report]()
    
    @State private var selectedUserReport: Report?
    
    @ObservedObject var userModel: UserViewModel
    @EnvironmentObject var notificationModel: NotificationViewModel
    @EnvironmentObject var reportsModel: ReportsViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 13) {
                ZStack {
                    switch userReports.isEmpty {
                    case true:
                        NoUserReportsView()
                    case false:
                        list
                    }
                }
            }
        }
        .onAppear {
            userModel.userReportsDelegate = reportsModel
            getUserReports()
        }
    }
    
    var list: some View {
        VStack {
            ForEach(userReports) { report in
                ReportCellView(report: report) {
                    getUserReports()
                }
                .onTapGesture {
                    self.selectedUserReport = report
                }
                Divider()
            }
        }
        .sheet(item: $selectedUserReport) { report in
            SelectedReportDetailView(report: report) {
                getUserReports()
            }
            .environmentObject(reportsModel)
        }
    }
    
    private func getUserReports() {
        userModel.getUserReports { status in
            switch status {
            case .success(let reports):
                self.userReports = reports
            case .failure(let reason):
                print(reason.localizedDescription)
            }
        }
    }
}
