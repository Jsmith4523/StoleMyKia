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
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    
                } label: {
                    Image(systemName: "mic")
                }
                Button {
                    reportsVM.isShowingLicensePlateScannerView.toggle()
                } label: {
                    Image(systemName: "camera")
                }
            }
        }
        .fullScreenCover(isPresented: $reportsVM.isShowingLicensePlateScannerView) {
            LicensePlateScannerView()
        }
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
