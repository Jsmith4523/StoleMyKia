//
//  UserReportsView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 5/28/23.
//

import Foundation
import SwiftUI

struct UserReportsView: View {
    
    @State private var refreshing = false
    
    @State private var userReports = [Report]()
    
    @State private var selectedUserReport: Report?
    
    @ObservedObject var userModel: UserViewModel
    @EnvironmentObject var notificationModel: NotificationViewModel
    @EnvironmentObject var reportsModel: ReportsViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 13) {
                GeometryReader { geo in
                    ZStack {
                        HStack {
                            Spacer()
                            Image(systemName: "arrow.counterclockwise")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geo.frame(in: .global).minY < 0 ? 0 :  geo.frame(in: .global).minY > 250 ? 25 : (geo.frame(in: .global).minY / 10), height: geo.frame(in: .global).minY < 0 ? 0 :  geo.frame(in: .global).minY > 250 ? 25 : (geo.frame(in: .global).minY / 10))
                                .padding()
                                .background(refreshing ? Color.brand : Color(uiColor: .secondarySystemBackground))
                                .clipShape(Circle())
                                .bold()
                                .foregroundColor(refreshing ? .white : .brand)
                                .padding()
                            Spacer()
                        }
                    }
                    .onChange(of: geo.frame(in: .global).minY) { newValue in
                        if newValue > 250 {
                            if !refreshing {
                                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                            }
                            
                            withAnimation {
                                refreshing = true
                            }
                        }
                    }
                }
                .frame(height: 50)
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
                ReportCellView(report: report)
                    .onTapGesture {
                        self.selectedUserReport = report
                    }
                Divider()
            }
        }
        //.background(Color.white)
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
