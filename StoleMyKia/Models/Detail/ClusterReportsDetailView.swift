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
    
    @EnvironmentObject var reportsModel: ReportsViewModel
    @EnvironmentObject var mapModel: MapViewModel
    
    @Environment (\.dismiss) var dismiss
        
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    ForEach(reports) { report in
                        ReportCellView(report: report)
                            .onTapGesture {
                                reportsModel.reportDetailMode = .single(report)
                            }
                        Divider()
                    }
                }
            }
            .navigationTitle("Reports")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ClusterDetail_Previews: PreviewProvider {
    static var previews: some View {
        MultipleReportsView(reports: [])
            .environmentObject(ReportsViewModel())
            .environmentObject(MapViewModel())
    }
}
