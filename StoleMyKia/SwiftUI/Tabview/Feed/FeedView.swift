//
//  FeedView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/10/23.
//

import SwiftUI
import CoreLocation

enum FeedLoadStatus {
    case loading, loaded, empty, error
}

struct FeedView: View {
    
    @State private var isShowingReportTypeFilterView = false
    @State private var isShowingNearbyMapView = false
    @State private var isShowingNewReportView = false
    
    //Filters
    @State private var filterByUserLocation = false
    @State private var nearbyDistance: NearbyDistance = .fiveMiles
    @State private var search = ""
    
    @State private var filterByReportType = false
    @State private var reportType: ReportType = .stolen
    
    @ObservedObject var userVM: UserViewModel
    @ObservedObject var reportsVM: ReportsViewModel
    
    private var filteredReports: [Report] {
        let reports = reportsVM.reports.filter { report in
            if filterByReportType {
                return report.reportType == reportType
            } else {
                return true
            }
        }.filter { report in
            if let userLocation = CLLocationManager.shared.location, filterByUserLocation {
                return report.location.location.distance(from: userLocation) <= nearbyDistance.distance
            } else {
                return true
            }
        }
        
        if search.isEmpty {
            return reports
        } else {
            return reports.filter({ report in
                let lowercasedSearch = search.lowercased()
                let hasDetails = report.vehicleDetails.lowercased().contains(lowercasedSearch)
                let hasLicense = report.vehicle.licensePlateString.lowercased().contains(lowercasedSearch)
                let hasVin = report.vehicle.vinString.contains(lowercasedSearch)
                let hasDescription = report.distinguishableDetails.contains(lowercasedSearch)
                
                return (hasDetails || hasLicense || hasVin || hasDescription)
            })
        }
    }
    
    private var isFiltering: Bool {
        return filterByReportType || filterByUserLocation
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                ScrollView {
                    switch reportsVM.feedLoadStatus {
                    case .loading:
                        ReportsSkeletonLoadingListView()
                    case .loaded:
                        FeedListView(reports: filteredReports)
                    case .empty:
                        NoReportsAvaliableView()
                    case .error:
                        ErrorView()
                    }
                }
            }
            .environmentObject(userVM)
            .environmentObject(reportsVM)
            .navigationTitle(ApplicationTabViewSelection.feed.title)
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await reportsVM.fetchReports()
            }
            .task {
                await onAppearFetchReports()
            }
            .searchable(text: $search)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        isShowingReportTypeFilterView.toggle()
                    } label: {
                        Image(systemName: isFiltering ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                            .foregroundColor(isFiltering ? .blue : Color(uiColor: .label))
                    }
                    Button {
                        isShowingNewReportView.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .onChange(of: nearbyDistance) { _ in
                reportsVM.reports = reportsVM.reports
            }
        }
        .sheet(isPresented: $isShowingNewReportView) {
            NewReportView()
                .environmentObject(reportsVM)
                .environmentObject(userVM)
        }
        .sheet(isPresented: $isShowingReportTypeFilterView) {
            ReportFilterView(filterByUserLocation: $filterByUserLocation, filterByReportType: $filterByReportType, nearbyDistance: $nearbyDistance, reportType: $reportType)
                .presentationDetents([.medium, .large])
        }
    }
    
    private func onAppearFetchReports() async {
        //Prevents the view from fetching for reports when the array is not empty
        guard reportsVM.reports.isEmpty else { return }
        await reportsVM.fetchReports()
    }
}

//#Preview {
//    FeedView(userVM: UserViewModel(), reportsVM: ReportsViewModel())
//        .tint(Color(uiColor: .label))
//        .preferredColorScheme(.dark)
//}
