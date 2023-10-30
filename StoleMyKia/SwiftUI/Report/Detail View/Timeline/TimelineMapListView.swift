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
                        updatesEmptyView
                    case .noLongerAvaliable:
                        reportNoLongerAvaliable
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
    
    var updatesEmptyView: some View {
        VStack {
            Spacer()
                .frame(height: 85)
            VStack(spacing: 11) {
                Image.updateImageIcon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
                Text("There are no updates available at the moment...")
                    .font(.system(size: 18))
            }
            .foregroundColor(.gray)
        }
        .padding()
        .multilineTextAlignment(.center)
    }
    
    var reportNoLongerAvaliable: some View {
        VStack {
            Spacer()
                .frame(height: 85)
            VStack(spacing: 11) {
                Image(systemName: "archivebox")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
                Text("Sorry, the initial report is no longer available.")
                    .font(.system(size: 18))
            }
            .foregroundColor(.gray)
        }
        .padding()
        .multilineTextAlignment(.center)
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
