//
//  ReportsFeedView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/10/23.
//

import SwiftUI

struct FeedListView: View {
            
    @State private var reports = [Report]()
    @State private var report: Report?
    
    @State private var isShowingFilterView = false
            
    @EnvironmentObject var reportsVM: ReportsViewModel
    @EnvironmentObject var userVM: UserViewModel
      
    var body: some View {
        ZStack {
            LazyVStack {
                LazyVStack(spacing: 25) {
                    LazyVStack(spacing: 15) {
                        ForEach(reports) { report in
                            ReportCellView(report: report)
                                .onTapGesture {
                                    self.report = report
                                }
                        }
                    }
                    .background(Color(uiColor: .opaqueSeparator).opacity(0.16))
                }
                Spacer()
                    .frame(height: 70)
            }
        }
        .environmentObject(reportsVM)
        .environmentObject(userVM)
        .fullScreenCover(item: $report) { report in
            ReportDetailView(reportId: report.id)
                .environmentObject(reportsVM)
                .environmentObject(userVM)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    self.isShowingFilterView.toggle()
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
        }
        .onReceive(reportsVM.$reports) { reports in
            self.reports = reports
        }
    }
}
