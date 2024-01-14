//
//  FeedDesiredView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/28/23.
//

import SwiftUI

enum FeedLoadStatus {
    case loading, loaded, empty, error, desiredLocationNotSet
}

struct FeedDesiredView: View {
    
    @State private var isShowingDesiredSettingsView = false
    
    @EnvironmentObject var reportsVM: ReportsViewModel
    @EnvironmentObject var userVM: UserViewModel
    
    var body: some View {
        ScrollView {
            switch reportsVM.feedLoadStatus {
            case .loading:
                ReportsSkeletonLoadingListView()
            case .loaded:
                FeedListView(reports: $reportsVM.reports)
            case .empty:
                NoReportsAvaliableView()
            case .error:
                ErrorView()
            case .desiredLocationNotSet:
                FeedNoDesiredLocationView()
            }
        }
        .task {
            await fetchReports()
        }
        .refreshable {
            await fetchReports(override: true)
        }
        .toolbar {
            Button {
                self.isShowingDesiredSettingsView.toggle()
            } label: {
                Image(systemName: "globe.americas.fill")
                    .foregroundColor(Color(uiColor: .label))
            }
        }
        .sheet(isPresented: $isShowingDesiredSettingsView) {
            NotificationSettingsView(completion: refreshReportsForDesiredLocation)
                .environmentObject(userVM)
        }
    }
    
    private func fetchReports(override: Bool = false) async {
        if !override {
            guard (reportsVM.reports.isEmpty) else { return }
        }
        await reportsVM.fetchReports()
    }
    
    private func refreshReportsForDesiredLocation() {
        Task {
            await reportsVM.fetchReports(showProgress: true)
        }
    }
}

#Preview {
    NavigationStack {
        FeedDesiredView()
            .environmentObject(UserViewModel())
            .environmentObject(ReportsViewModel())
    }
}
