//
//  ReportsFeedView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/10/23.
//

import SwiftUI

enum CellViewImageMode {
    case large, thumbnail
}

struct FeedListView: View {
            
    @Binding var reports: [Report]
    @State private var report: Report?
    
    var cellImageMode: CellViewImageMode = .large
    var onDeleteCompletion: (() -> ())? = nil
                
    @EnvironmentObject var reportsVM: ReportsViewModel
    @EnvironmentObject var userVM: UserViewModel
      
    var body: some View {
        ZStack {
            LazyVStack {
                LazyVStack(spacing: 25) {
                    LazyVStack(spacing: 12) {
                        ForEach(reports) { report in
                            ReportCellView(report: report, imageMode: cellImageMode)
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
            ReportDetailView(reportId: report.id, deleteCompletion: onDeleteCompletion)
                .environmentObject(reportsVM)
                .environmentObject(userVM)
        }
    }
}
