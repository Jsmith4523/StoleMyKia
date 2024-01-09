//
//  TimelineMapListView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/13/23.
//

import SwiftUI

enum TimelineListViewMode {
    case loading, loaded([Report]), empty, error, noLongerAvaliable
}

struct TimelineMapListView: View {
    
    @State private var shouldDismiss = false
    
    @EnvironmentObject var timelineMapVM: TimelineMapViewModel
    @EnvironmentObject var reportsVM: ReportsViewModel
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: .systemBackground).ignoresSafeArea()
                ScrollView {
                    switch timelineMapVM.timelineListMode {
                    case .loading:
                        TimelineMapListSkeletonView()
                    case .loaded(let reports):
                        TimelineListView(shouldDismiss: $shouldDismiss, reports: reports)
                            .environmentObject(timelineMapVM)
                    case .error:
                        ErrorView()
                    case .empty:
                        TimelineMapListNoUpdatesView()
                    case .noLongerAvaliable:
                        TimelineMapListNotAvaliableView()
                    }
                }
                .navigationTitle("Timeline")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .tint(Color(uiColor: .label))
        .onChange(of: shouldDismiss) { value in
            if value {
                dismiss()
            }
        }
    }
    
    private func fetchUpdates() {
        Task {
            try? await timelineMapVM.getUpdatesForReport(timelineMapVM.reportId)
        }
    }
}

//#Preview {
//    TimelineMapListView()
//        .environmentObject(ReportsViewModel())
//        .environmentObject(TimelineMapViewModel())
//}
