//
//  UserBookmarksView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/16/23.
//

import SwiftUI

struct UserBookmarksView: View {
        
    @State private var userBookmarksLoadStatus: UserReportsLoadStatus = .loading
    @State private var reports = [Report]()
    
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var reportsVM: ReportsViewModel
    
    var body: some View {
        ScrollView {
            switch userBookmarksLoadStatus {
            case .loading:
                ReportSkeletonView()
            case .loaded:
                FeedListView(reports: reports)
            case .empty:
                UserBookmarksEmptyView()
            case .error:
                ErrorView()
            }
        }
        .refreshable {
            try? await userVM.fetchUserBookmarks()
        }
        .onReceive(userVM.$userBookmarks) { reports in
            self.reports = reports
        }
        .environmentObject(userVM)
        .environmentObject(reportsVM)
        .task {
            await onAppearFetchUserBookmarks()
        }
    }
    
    private func onAppearFetchUserBookmarks() async {
        guard reports.isEmpty else { return }
        do {
            try await userVM.fetchUserReports()
            guard !(userVM.userBookmarks.isEmpty) else {
                self.userBookmarksLoadStatus = .empty
                return
            }
            self.userBookmarksLoadStatus = .loaded
        } catch {
            self.userBookmarksLoadStatus = .error
        }
    }
}

struct UserBookmarksView_Previews: PreviewProvider {
    static var previews: some View {
        UserBookmarksView()
            .environmentObject(UserViewModel())
            .environmentObject(ReportsViewModel())
    }
}
