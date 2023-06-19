//
//  TimelineMapView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/11/23.
//

import SwiftUI

struct TimelineMapView: View {
    
    @State private var isShowingNewUpdateView = false
    @State private var isShowingHowUpdatesWorkView = false
    
    let report: Report
    
    @StateObject private var timelineMapCoordinator = TimelineMapViewCoordinator()
    
    @EnvironmentObject var reportsVM: ReportsViewModel
    
    var body: some View {
        VStack {
            TimelineMapViewRepresentabe(report: report, timelineMapCoordinator: timelineMapCoordinator)
            ScrollView {
                noTimelineView
            }
            .refreshable {
                
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text("Timeline")
                        .font(.system(size: 15).bold())
                    Text("\(timelineMapCoordinator.updates.count) avaliable")
                        .font(.system(size: 12))
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isShowingNewUpdateView.toggle()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .environmentObject(reportsVM)
        .sheet(isPresented: $isShowingNewUpdateView) {
            UpdateReportView(report: report)
                .interactiveDismissDisabled()
        }
    }
    
    private var timelineList: some View {
        VStack {
            ForEach(timelineMapCoordinator.updates.sorted(by: >)) { report in
                NavigationLink {
                    
                } label: {
                    TimelineMapView(report: report)
                }
                Divider()
                    .padding(.horizontal)
            }
        }
        .refreshable {
            
        }
    }
    
    private var noTimelineView: some View {
        VStack(spacing: 14) {
            Spacer()
                .frame(height: 20)
            Image(systemName: "clock.arrow.circlepath")
                .resizable()
                .scaledToFit()
                .frame(width: 45, height: 45)
                .bold()
            Text("Updates for this report will appear once someone identifies and reports this vehicle.")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .frame(width: 300)
                .padding()
        }
        .multilineTextAlignment(.center)
        .sheet(isPresented: $isShowingHowUpdatesWorkView) {
            
        }
    }
}

fileprivate struct TimelineMapUpdateCellView: View {
    
    @State private var vehicleImage: UIImage?
    
    let report: Report
    
    @EnvironmentObject var userModel: UserViewModel
    @EnvironmentObject var reportsModel: ReportsViewModel
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(report.reportType.rawValue)
                    .font(.system(size: 23).bold())
                Text(report.dt.full)
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                HStack {
                    if let locationName = report.location.name {
                        Label(locationName, systemImage: "mappin.and.ellipse")
                    }
                }
                .font(.system(size: 15).bold())
            }
            Spacer()
            if report.hasVehicleImage {
                Image(uiImage: vehicleImage ?? .vehiclePlaceholder)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 75, height: 75)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding()
        .onAppear {
            report.vehicleImage { image in
                self.vehicleImage = image
            }
        }
        .contextMenu {
            Button {
                URL.getDirectionsToLocation(coords: report.location.coordinates)
            } label: {
                Label("Get Directions", systemImage: "map")
            }
        }
    }
}

struct TimelineMapView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TimelineMapView(report: .init(dt: Date.now.epoch, reportType: .found, vehicle: .init(vehicleYear: 2017, vehicleMake: .hyundai, vehicleColor: .black, vehicleModel: .kona), distinguishable: "", imageURL: "https://s3.us-east-2.amazonaws.com/dealer-inspire-vps-vehicle-images/c447-110005591/KM8K62AB0PU009265/7e3811453af8f6f40c7dcffda76f07e3.jpg", location: .init(name: "Grand Central Station", lat: 40.75110, lon: -73.97838), role: .original))
                .environmentObject(ReportsViewModel())
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
