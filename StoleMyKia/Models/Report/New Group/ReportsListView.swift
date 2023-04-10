//
//  ReportsListView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 4/9/23.
//

import Foundation
import SwiftUI
import MapKit

struct ReportListView: View {
    
    @EnvironmentObject var reportsModel: ReportsViewModel
    
    private let imageCache = ImageCache()
    
    var body: some View {
        NavigationView {
            ListView(reports: $reportsModel.reports, imageCache: imageCache)
                .navigationTitle("Reports")
                .navigationBarTitleDisplayMode(.inline)
        }
        .environmentObject(reportsModel)
    }
}

struct ReportListView_Previews: PreviewProvider {
    static var previews: some View {
        ReportListView()
            .environmentObject(ReportsViewModel())
    }
}
