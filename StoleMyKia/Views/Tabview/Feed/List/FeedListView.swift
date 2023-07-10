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
            Color(uiColor: .opaqueSeparator).opacity(0.16).ignoresSafeArea()
            VStack(spacing: 25) {
                ForEach(reports) { report in
                    ReportCellView(report: report)
                        .onTapGesture {
                            self.selectedReport = report
                        }
                }
            }
        }
        .environmentObject(reportsVM)
        .environmentObject(userModel)
        .sheet(item: $selectedReport) { report in
            SelectedReportDetailView(report: report)
                .presentationDragIndicator(.visible)
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
            }
        }
    }
}
