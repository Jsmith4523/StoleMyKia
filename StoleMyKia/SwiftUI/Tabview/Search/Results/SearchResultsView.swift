//
//  SearchResultsView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/28/23.
//

import SwiftUI

enum SearchResultsLoadStatus {
    case loading, loaded, empty, error
}

struct SearchResultsView: View {
    
    @State private var reports = [Report]()
    @State private var reportType: ReportType?
    
    @EnvironmentObject var searchVM: SearchViewModel
    @EnvironmentObject var reportsVM: ReportsViewModel
    @EnvironmentObject var userVM: UserViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            SearchReportTypeFilterView(reportType: $reportType)
            ScrollView {
                switch searchVM.searchLoadStatus {
                case .loading:
                    ReportsSkeletonLoadingListView()
                case .loaded:
                    FeedListView(reports: $reports, cellImageMode: .thumbnail, onDeleteCompletion: refresh)
                        .environmentObject(reportsVM)
                        .environmentObject(userVM)
                case .empty:
                    SearchResultsEmptyView()
                case .error:
                    ErrorView()
                }
            }
            /*Devices before iOS 17.0 are having issues where this view does the following:
             
             1) Does not update color scheme unless the view is dismissed and re-presented.
             2) ScrollView and UITabBar issue where the UITabBar visibly shows tab items over cell views.
             
             */
        }
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(searchVM.$reports) { reports in
            if let reportType {
                self.reports = reports.filter({$0.reportType == reportType})
            } else {
                self.reports = reports
            }
        }
        .onChange(of: reportType) { _ in
            if let reportType {
                self.reports = searchVM.reports.filter({$0.reportType == reportType})
            } else {
                self.reports = searchVM.reports
            }
        }
        .task {
            await searchVM.fetchReportsForSearch(override: true)
        }
        .refreshable {
            await searchVM.fetchReportsForSearch()
        }
    }
    
    private func refresh() {
        Task {
            await searchVM.fetchReportsForSearch()
        }
    }
}

#Preview {
    SearchResultsView()
        .environmentObject(SearchViewModel())
        .environmentObject(ReportsViewModel())
        .environmentObject(UserViewModel())
}
