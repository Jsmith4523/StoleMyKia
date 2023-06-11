//
//  ReportsFeedView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/10/23.
//

import SwiftUI

struct FeedListView: View {
    
    @EnvironmentObject var reportsVM: ReportsViewModel
    @EnvironmentObject var userModel: UserViewModel
    
    @Binding var reports: [Report]
    
    var body: some View {
        ZStack {
            Color(uiColor: .opaqueSeparator).opacity(0.16).ignoresSafeArea()
            VStack(spacing: 25) {
                ForEach(reports) { report in
                    NavigationLink {
                        SelectedReportDetailView(report: report)
                    } label: {
                        ReportCellView(report: report)
                    }
                }
            }
        }
        .environmentObject(reportsVM)
        .environmentObject(userModel)
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
