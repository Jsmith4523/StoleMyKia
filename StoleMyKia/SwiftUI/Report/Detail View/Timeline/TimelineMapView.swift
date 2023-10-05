//
//  TimelineMapView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/11/23.
//

import SwiftUI
import MapKit

struct TimelineMapView: View {
    
    enum DetailMode {
        case report(Report)
        case reportId(UUID)
    }
            
    let detailMode: DetailMode
        
    @StateObject private var timelineMapCoordinator = TimelineMapViewCoordinator()
    @EnvironmentObject var reportsVM: ReportsViewModel
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack(alignment: .top) {
                    TimelineMapViewRepresentabe(timelineMapCoordinator: timelineMapCoordinator)
                        .edgesIgnoringSafeArea(.bottom)
                    if let report = timelineMapCoordinator.report {
                        Text(report.vehicleDetails)
                            .font(.system(size: 12.5).weight(.medium))
                            .padding(10)
                            .background(Color(uiColor: .systemBackground))
                            .clipShape(Capsule())
                            .padding()
                    }
                }
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
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            fetchForUpdates()
        }
        .alert("Alert", isPresented: $timelineMapCoordinator.showAlert) {
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
                SelectedReportDetailView(report: report, timelineMapViewMode: .dismissWhenSelected, deleteCompletion: fetchForUpdates)
                    .environmentObject(reportsVM)
            }
        }
    }
    
    private func fetchForUpdates() {
        Task {
            switch detailMode {
            case .report(let report):
                await timelineMapCoordinator.getUpdates(report)
            case .reportId(_):
                break
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
        TimelineMapView(detailMode: .report([Report].testReports().first!))
            .environmentObject(ReportsViewModel())
            .preferredColorScheme(.dark)
    }
}
