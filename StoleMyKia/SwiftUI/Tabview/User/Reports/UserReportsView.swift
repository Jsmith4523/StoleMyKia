//
//  UserReportsView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/16/23.
//

import SwiftUI

struct UserReportsView: View {
    
    enum UserReportsLoadStatus {
        case loading, loaded, empty, error
    }
    
    @EnvironmentObject var reportsVM: ReportsViewModel
    @EnvironmentObject var userVM: UserViewModel
    
    @State private var userReportsLoadStatus: UserReportsLoadStatus = .loading
    
    @State private var reports = [Report]()
            
    var body: some View {
        ScrollView {
            switch userReportsLoadStatus {
            case .loading:
                ReportsSkeletonLoadingListView()
            case .loaded:
                FeedListView(reports: $reports)
            case .empty:
                Text("Empty")
            case .error:
                Text("Error")
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
        .refreshable {
            try? await userVM.fetchUserReports()
        }
    }
    
    private func onAppearFetchUserReports() async {
        guard reports.isEmpty else { return }
        do {
            try await userVM.fetchUserReports()
            guard !(userVM.userReports.isEmpty) else {
                self.userReportsLoadStatus = .empty
                return
            }
            self.userReportsLoadStatus = .loaded
        } catch {
            print(error.localizedDescription)
            self.userReportsLoadStatus = .error
        }
    }
}

struct UserReportsView_Previews: PreviewProvider {
    static var previews: some View {
        UserReportsView()
            .environmentObject(UserViewModel())
            .environmentObject(ReportsViewModel())
    }
}
