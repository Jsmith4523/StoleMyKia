//
//  FeedView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/10/23.
//

import SwiftUI

enum FeedLoadStatus {
    case loading, loaded
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
                        ProgressView()
                    case .loaded:
                        switch reportsVM.reports.isEmpty {
                        case true:
                            NoReportsAvaliableView()
                        case false:
                            FeedListView(reports: $reportsVM.reports)
                        }
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
                Button {
                    isShowingNearbyMapView.toggle()
                } label: {
                    Image(systemName: "map")
                }
                Button {
                    isShowingNewReportView.toggle()
                } label: {
                    Image(systemName: "exclamationmark.bubble")
                }
            }
        }
        .sheet(isPresented: $isShowingNewReportView) {
            NewReportView()
                .environmentObject(reportsVM)
                .environmentObject(userVM)
        }
        .fullScreenCover(isPresented: $isShowingNearbyMapView) {
            
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
