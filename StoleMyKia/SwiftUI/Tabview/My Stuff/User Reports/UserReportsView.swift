//
//  UserReportsView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/3/23.
//

import SwiftUI

struct UserReportsView: View {
    
    @EnvironmentObject var userReportsVM: UserReportsViewModel
    @EnvironmentObject var reportsVM: ReportsViewModel
    
    var body: some View {
        ScrollView {
            ZStack {
                switch userReportsVM.reportsLoadStatus {
                case .loading:
                    ReportSkeletonView()
                case .loaded:
                    FeedListView(reports: userReportsVM.reports)
                case .empty:
                    UserReportsEmptyView()
                case .error:
                    ErrorView()
                }
            }
        }
        .refreshable {
            try? await userReportsVM.fetchUserReports()
        }
        .task {
            try? await userReportsVM.fetchUserReports()
        }
    }
}

struct UserReportsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UserReportsView()
                .environmentObject(ReportsViewModel())
                .environmentObject(UserReportsViewModel())
        }
    }
}
