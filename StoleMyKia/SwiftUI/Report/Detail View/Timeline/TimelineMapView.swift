//
//  TimelineMapView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/11/23.
//

import SwiftUI
import MapKit

struct TimelineMapView: View {
    
    enum DismissButtonStyle {
        case navigation, dismiss
        
        var symbol: String {
            switch self {
            case .dismiss:
                return "xmark"
            case .navigation:
                return "arrow.left"
            }
        }
    }
    
    let reportAssociatedId: UUID
    var dismissStyle: DismissButtonStyle = .navigation
            
    @StateObject private var timelineMapVM = TimelineMapViewModel()
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        ZStack(alignment: .leading) {
            ZStack(alignment: .bottomTrailing) {
                ZStack(alignment: .topLeading) {
                    TimelineMap(viewModel: timelineMapVM)
                    header
                }
            }
        }
        .navigationTitle("Timeline")
        .navigationBarHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .environmentObject(timelineMapVM)
        .task {
            try? await timelineMapVM.getUpdatesForReport(reportAssociatedId)
        }
        .customSheetView(isPresented: $timelineMapVM.isShowingListView, detents: .timelineMapListDetents, showsIndicator: true, cornerRadius: 30) {
            TimelineMapListView()
                .environmentObject(timelineMapVM)
        }
        .sheet(item: $timelineMapVM.selectedReport) { report in
            TimelineReportDetailView(report: report)
                .presentationDragIndicator(.visible)
                .presentationDetents([.height(250), .height(750)])
                .environmentObject(timelineMapVM)
        }
    }
    
    var header: some View {
        HStack(alignment: .top) {
            Button {
               dismiss()
            } label: {
                Image(systemName: dismissStyle.symbol)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color(uiColor: .systemBackground))
                    .padding(10)
                    .background(Color(uiColor: .label))
                    .clipShape(Circle())
            }
            Spacer()
            Text(timelineMapVM.isLoading ? "Loading..." : "Refresh")
                .font(.system(size: 16).weight(.heavy))
                .foregroundColor(Color(uiColor: .systemBackground))
                .padding(10)
                .background(Color(uiColor: .label))
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .onTapGesture {
                    refreshTimeline()
                }
                .disabled(timelineMapVM.isLoading)
            Spacer()
            VStack(spacing: 18) {
                Button {
                    timelineMapVM.isShowingListView.toggle()
                } label: {
                    Image(systemName: "line.3.horizontal.decrease")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color(uiColor: .systemBackground))
                        .padding(10)
                        .background(Color(uiColor: .label))
                        .clipShape(Circle())
                }
                Button {
                    timelineMapVM.moveToUsersLocation()
                } label: {
                    Image(systemName: "location")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(.blue)
                        .clipShape(Circle())
                }
            }
        }
        .padding()
    }
    
    private func refreshTimeline() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        Task {
            try? await timelineMapVM.getUpdatesForReport(reportAssociatedId)
        }
    }
}

struct TimelineMapView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TimelineMapView(reportAssociatedId: [Report].testReports().first!.role.associatedValue)
                .environmentObject(ReportsViewModel())
        }
    }
}
