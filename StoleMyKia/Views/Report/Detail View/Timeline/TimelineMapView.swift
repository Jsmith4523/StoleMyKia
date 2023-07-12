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
            }
        }
        .environmentObject(reportsVM)
        .sheet(item: $timelineMapCoordinator.selectedUpdateReport) { report in
            SelectedReportDetailView(report: report, timelineMapViewMode: .dismissWhenSelected)
                .environmentObject(reportsVM)
        }
        .task {
            await timelineMapCoordinator.getUpdates(report: report)
        }
        .alert("Uh oh", isPresented: $timelineMapCoordinator.showAlert) {
            Button("Okay") { dismiss() }
        } message: {
            Text(timelineMapCoordinator.alertReportError?.rawValue ?? "There was an error")
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
