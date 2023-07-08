//
//  FeedView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/10/23.
//

import SwiftUI

struct FeedView: View {
    
    @State private var isShowingNewReportView = false
    @State private var reports = [Report]()
    
    @EnvironmentObject var userModel: UserViewModel
    @EnvironmentObject var reportsVM: ReportsViewModel
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                ScrollView {
                    switch reports.isEmpty {
                    case true:
                        NoReportsAvaliableView()
                    case false:
                        FeedListView(reports: $reports)
                    }
                }
            }
            .environmentObject(userModel)
            .environmentObject(reportsVM)
            .navigationTitle(ApplicationTabViewSelection.feed.title)
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                reportsVM.getReports()
            }
            .onAppear {
                reportsVM.getReports()
            }
            .onReceive(reportsVM.$reports) { reports in
                self.reports = reports
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        FeedSearchView(reports: $reports)
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                    Button {
                        
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingNewReportView) {
            NewReportView()
                .tint(.brand)
        }
        .environmentObject(reportsVM)
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
