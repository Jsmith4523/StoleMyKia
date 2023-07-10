//
//  TimelineMapView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/11/23.
//

import SwiftUI
import MapKit

enum MapViewType: String, CaseIterable, Identifiable {
    case standard = "Standard"
    case birdsEye = "Birds Eye"
    
    var id: String {
        self.rawValue
    }
    
    var mapType: MKMapType {
        switch self {
        case .standard:
            return .mutedStandard
        case .birdsEye:
            return .hybrid
        }
    }
}

struct TimelineMapView: View {
    
    @State private var presentMapOptions = false
    
    let report: Report
    
    @StateObject private var timelineMapCoordinator = TimelineMapViewCoordinator()
    @EnvironmentObject var reportsVM: ReportsViewModel
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                TimelineMapViewRepresentabe(report: report, timelineMapCoordinator: timelineMapCoordinator)
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        presentMapOptions.toggle()
                    } label: {
                        Image(systemName: "map")
                    }
                }
            }
            .confirmationDialog("", isPresented: $presentMapOptions) {
                ForEach(MapViewType.allCases) { mapType in
                    Button(mapType.rawValue) {
                        timelineMapCoordinator.mapViewType = mapType
                    }
                }
            }
        }
        .environmentObject(reportsVM)
    }
}

struct TimelineMapView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineMapView(report: [Report].testReports().first!)
            .environmentObject(ReportsViewModel())
            .preferredColorScheme(.dark)
    }
}
