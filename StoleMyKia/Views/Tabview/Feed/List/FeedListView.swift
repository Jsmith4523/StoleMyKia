//
//  ReportsFeedView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/10/23.
//

import SwiftUI

struct FeedListView: View {
    
    @State private var selectedReport: Report?
    
    @Binding var reports: [Report]
    
    @EnvironmentObject var reportsVM: ReportsViewModel
    @EnvironmentObject var userModel: UserViewModel
        
    var body: some View {
        ZStack {
            VStack(spacing: 11) {
                ForEach(reports.sorted(by: >)) { report in
                    ReportCellView(report: report)
                        .onTapGesture {
                            self.selectedReport = report
                        }
                }
            }
            .background(Color(uiColor: .opaqueSeparator).opacity(0.16))
        }
        .environmentObject(reportsVM)
        .environmentObject(userModel)
        .sheet(item: $selectedReport) { report in
            SelectedReportDetailView(report: report)
                .environmentObject(reportsVM)
                .environmentObject(userModel)
        }
    }
}

struct ReportsFeedView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ScrollView {
                FeedListView(reports: .constant(.testReports()))
                    .environmentObject(ReportsViewModel())
                    .environmentObject(UserViewModel())
                    .preferredColorScheme(.dark)
            }
        }
    }
}
