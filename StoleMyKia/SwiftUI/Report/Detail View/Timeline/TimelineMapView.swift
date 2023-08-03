//
//  TimelineMapView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/11/23.
//

import SwiftUI
import MapKit

struct TimelineMapView: View {
            
    let report: Report
    
    @StateObject private var timelineMapCoordinator = TimelineMapViewCoordinator()
    @EnvironmentObject var reportsVM: ReportsViewModel
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                TimelineMapViewRepresentabe(timelineMapCoordinator: timelineMapCoordinator)
                    .edgesIgnoringSafeArea(.bottom)
            }
            .navigationTitle("Timeline")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if timelineMapCoordinator.isLoading {
                        ProgressView()
                    } else {
                        Button {
                            refresh()
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                    
                    if !(timelineMapCoordinator.isLoading) {
                        Button {
                            timelineMapCoordinator.mapViewSheetMode = .list
                        } label: {
                            Image(systemName: "list.dash")
                        }
                    }
                }
            }
        }
        .environmentObject(reportsVM)
        .onAppear {
            timelineMapCoordinator.setDelegate(reportsVM)
        }
        .onDisappear {
            timelineMapCoordinator.suspendTask()
        }
        .task {
            await timelineMapCoordinator.getUpdates(report)
        }
        .alert("Uh oh", isPresented: $timelineMapCoordinator.showAlert) {
            Button("Okay") { dismiss() }
        } message: {
            Text(timelineMapCoordinator.alertReportError?.rawValue ?? "There was an error")
        }
        .sheet(item: $timelineMapCoordinator.mapViewSheetMode) { mode in
            switch mode {
            case .list:
                TimelineListView()
                    .environmentObject(timelineMapCoordinator)
            case .report(let report):
                SelectedReportDetailView(report: report, timelineMapViewMode: .dismissWhenSelected)
                    .environmentObject(reportsVM)
            }
        }
    }
    
    private func refresh() {
        Task {
            await timelineMapCoordinator.refreshForNewUpdates()
        }
    }
}

struct TimelineMapView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineMapView(report: [Report].testReports().first!)
            .environmentObject(ReportsViewModel())
            .preferredColorScheme(.dark)
    }
}
