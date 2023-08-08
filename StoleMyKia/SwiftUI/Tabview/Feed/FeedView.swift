//
//  FeedView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/10/23.
//

import SwiftUI

enum FeedLoadStatus {
    case loading, loaded, empty, error
}

struct FeedView: View {
    
    @State private var isShowingNearbyMapView = false
    @State private var isShowingNewReportView = false
    
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var reportsVM: ReportsViewModel
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                ScrollView {
                    switch reportsVM.feedLoadStatus {
                    case .loading:
                        ReportsSkeletonLoadingListView()
                    case .loaded:
                        FeedListView(reports: $reportsVM.reports)
                    case .empty:
                        NoReportsAvaliableView()
                    case .error:
                        Color.orange
                    }
                }
            }
            .environmentObject(userVM)
            .environmentObject(reportsVM)
            .navigationTitle(ApplicationTabViewSelection.feed.title)
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await reportsVM.fetchReports()
            }
            .task {
                await onAppearFetchReports()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingNewReportView.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingNewReportView) {
            NewReportView()
                .environmentObject(reportsVM)
                .environmentObject(userVM)
        }
    }
    
    private func onAppearFetchReports() async {
        //Prevents the view from fetching for reports when the array is not empty
        guard reportsVM.reports.isEmpty else { return }
        await reportsVM.fetchReports()
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
            .environmentObject(UserViewModel())
            .environmentObject(ReportsViewModel())
            .tint(Color(uiColor: .label))
    }
}
