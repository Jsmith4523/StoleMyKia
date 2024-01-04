//
//  FeedLocalView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/28/23.
//

import SwiftUI

enum LocalReportsStatus {
    case loading, loaded, empty, error, locationDisabled
}

struct FeedLocalView: View {
    
    @EnvironmentObject var reportsVM: ReportsViewModel
    @EnvironmentObject var userVM: UserViewModel
    
    var body: some View {
        ScrollView {
            switch reportsVM.localReportsStatus {
            case .loading:
                ReportsSkeletonLoadingListView()
            case .loaded:
                FeedListView(reports: $reportsVM.localReports)
            case .empty:
                UserReportsEmptyView()
            case .error:
                ErrorView()
            case .locationDisabled:
                FeedLocationServicesDisabledView()
            }
        }
        .refreshable {
            await fetchLocalReports(override: true)
        }
        .task {
            await fetchLocalReports()
        }
    }
    
    private func fetchLocalReports(override: Bool = false) async {
        if !override {
            guard reportsVM.localReports.isEmpty else { return }
        }
        await reportsVM.fetchLocalReports()
    }
}

#Preview {
    FeedLocalView()
}
