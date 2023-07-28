//
//  UserReportsView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/16/23.
//

import SwiftUI

struct UserReportsView: View {
    
    enum UserReportsLoadStatus {
        case loading, loaded
    }
    
    @EnvironmentObject var reportsVM: ReportsViewModel
    @EnvironmentObject var userVM: UserViewModel
    
    @State private var userReportsLoadStatus: UserReportsLoadStatus = .loading
    
    @State private var reports = [Report]()
            
    var body: some View {
        ZStack {
            switch userReportsLoadStatus {
            case .loading:
                ReportSkeletonView()
            case .loaded:
                list
            }
        }
        .environmentObject(reportsVM)
        .environmentObject(userVM)
        .task {
            await onAppearFetchUserReports()
        }
        .onReceive(userVM.$userReports) { reports in
            self.reports = reports
        }
    }
    
    private var list: some View {
        VStack {
            switch reports.isEmpty {
            case true:
                Text("Your reports are empty")
            case false:
                ScrollView {
                    FeedListView(reports: $reports)
                        .environmentObject(reportsVM)
                        .environmentObject(userVM)
                }
                .refreshable {
                    await userVM.fetchUserReports()
                }
            }
        }
    }
    
    private func onAppearFetchUserReports() async {
        guard reports.isEmpty else { return }
        await userVM.fetchUserReports()
        self.userReportsLoadStatus = .loaded
    }
}

struct UserReportsView_Previews: PreviewProvider {
    static var previews: some View {
        UserReportsView()
            .environmentObject(UserViewModel())
            .environmentObject(ReportsViewModel())
    }
}
