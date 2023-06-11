//
//  FeedView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/10/23.
//

import SwiftUI

struct FeedView: View {
    
    @State private var isShowingNewReportView = false
    @State private var reports: [Report] = .testReports()
    
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
            .navigationTitle("Feed")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                
            }
            .onReceive(reportsVM.$reports) { reports in
                //self.reports = reports
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .bold()
                    }
                    Button {
                        
                    } label: {
                        Image(systemName: "plus")
                            .bold()
                    }
                }
            }
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
            .environmentObject(UserViewModel())
            .environmentObject(ReportsViewModel())
    }
}
