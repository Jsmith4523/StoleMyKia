//
//  FeedSearchView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/11/23.
//

import SwiftUI

struct FeedSearchView: View {
    
    @Binding var reports: [Report]
    @State private var searchField = ""
    
    @EnvironmentObject var reportsVM: ReportsViewModel
    
    var body: some View {
        VStack {
            FeedSearchResultsView(reports: $reports, searchField: $searchField)
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func getReportsWithFilter() {
        
    }
}

struct FeedSearchView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FeedSearchView(reports: .constant(.testReports()))
                .environmentObject(ReportsViewModel())
        }
    }
}
