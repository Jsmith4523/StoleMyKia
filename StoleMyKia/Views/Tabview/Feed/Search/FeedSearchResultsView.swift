//
//  FeedSearchResultsView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/11/23.
//

import SwiftUI

struct FeedSearchResultsView: View {
    
    @Binding var reports: [Report]
    
    @Binding var searchField: String
    @State private var isShowingFilterView = false
        
    @State private var filterSelection: ReportType?
    @State private var vehicleYear: Int?
    @State private var vehicleMake: VehicleMake?
    @State private var vehicleModel: VehicleModel?
    @State private var vehicleColor: VehicleColor?
    
    @EnvironmentObject var reportsVM: ReportsViewModel
    
    private var filteredReports: [Report] {
        let filteredReports = [Report].testReports().filter { report in
            let matches = report.matches(year: vehicleYear, type: filterSelection, make: vehicleMake, model: vehicleModel, color: vehicleColor, input: searchField)
            print(matches)
            return matches
        }
        
        return filteredReports
    }
    
    var body: some View {
        VStack {
            FeedListFilterView(filterSelection: $filterSelection)
            ScrollView {
                switch filteredReports.isEmpty {
                case true:
                    noResultsView
                case false:
                    searchList
                }
            }
            .refreshable {
               
            }
        }
        .environmentObject(reportsVM)
        .sheet(isPresented: $isShowingFilterView) {
            FeedVehicleFilterView(vehicleYear: $vehicleYear, vehicleMake: $vehicleMake, vehicleModel: $vehicleModel)
            .presentationDragIndicator(.visible)
            .presentationDetents([.height(600)])
        }
    }
    
    var noResultsView: some View {
        VStack {
            Spacer()
                .frame(height: 135)
            VStack(spacing: 15) {
                Image(systemName: "folder")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 55, height: 55)
                Text("Sorry, we haven't recieved anything yet. You can pull this screen to refresh and try again.")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 17))
                    .foregroundColor(.gray)
                    .lineSpacing(0.75)
            }
        }
        .padding()
    }
    
    private var searchList: some View {
        ZStack {
            Color(uiColor: .opaqueSeparator).opacity(0.2)
            VStack(spacing: 22) {
                ForEach(filteredReports) { report in
                    NavigationLink {
                        SelectedReportDetailView(reportID: report.id)
                    } label: {
                        ReportCellView(report: report)
                    }
                }
            }
        }
    }
}

struct FeedSearchResultsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FeedSearchResultsView(reports: .constant(.testReports()), searchField: .constant(""))
                .environmentObject(ReportsViewModel())
                //.preferredColorScheme(.dark)
        }
    }
}
