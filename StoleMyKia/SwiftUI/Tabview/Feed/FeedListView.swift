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
            VStack {
                LazyVStack(spacing: 8) {
                    //FIXME: With Lazy VStack, the report type label within the cell view changes to an incorrect type when incorporating the cell view as a button label.
                    //FIXME: Changing to using an tap gesture, the application isn't registering the tap at times. Will continue to use tap gesture unless someone complains about it in the 1.0.
                    ForEach(reports) { report in
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            self.report = report
                        } label: {
                            ReportCellView(report: report, imageMode: cellImageMode)
                        }
                    }
                }
                .background(Color(uiColor: .opaqueSeparator).opacity(0.14))
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
