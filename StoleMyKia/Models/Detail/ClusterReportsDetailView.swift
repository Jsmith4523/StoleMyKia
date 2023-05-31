//
//  ClusterReportsDetailView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 5/28/23.
//

import Foundation
import SwiftUI


struct MultipleReportsView: View {
        
    let reports: [Report]
    
    @State private var reportTypeFilter: ReportType? {
        didSet {
            print(reportTypeFilter?.rawValue)
        }
    }
    
    @EnvironmentObject var reportsModel: ReportsViewModel
    @EnvironmentObject var mapModel: MapViewModel
    
    @Environment (\.dismiss) var dismiss
    
    var filteredReports: [Report] {
        guard let reportTypeFilter else {
            return reports
        }
        
        return reports.filter({$0.reportType == reportTypeFilter})
    }
        
    var body: some View {
        NavigationView {
            ZStack {
                switch filteredReports.isEmpty {
                case true:
                    noReportsView
                case false:
                    reportsListView
                }
            }
            .navigationTitle("Reports")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Menu {
                    if !(reportTypeFilter == nil) {
                        Button("Reset", role: .destructive) { reportTypeFilter = nil }
                    }
                    ForEach(ReportType.allCases) { type in
                        Button {
                            reportTypeFilter = type
                        } label: {
                            Text(type.rawValue)
                        }
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease")
                }
            }
        }
    }
    
    var reportsListView: some View {
        ScrollView {
            VStack {
                ForEach(filteredReports) { report in
                    ReportCellView(report: report) {
                        dismiss()
                    }
                    .onTapGesture {
                        reportsModel.reportDetailMode = .single(report)
                    }
                    Divider()
                }
            }
        }
    }
    
    var noReportsView: some View {
        VStack(spacing: 15) {
            Spacer()
            Image(systemName: "folder")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(.brand)
            Text("Nothing Found")
                .font(.system(size: 25).weight(.heavy))
            Text("Sorry, nothing was found by that criteria...")
                .font(.system(size: 17))
                .foregroundColor(.gray)
            Spacer()
        }
        .multilineTextAlignment(.center)
        .padding()
    }
}

struct ClusterDetail_Previews: PreviewProvider {
    static var previews: some View {
        MultipleReportsView(reports: []).noReportsView
            .environmentObject(ReportsViewModel())
            .environmentObject(MapViewModel())
    }
}
