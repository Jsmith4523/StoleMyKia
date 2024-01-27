//
//  SearchViewModel.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/28/23.
//

import Foundation

@MainActor
final class SearchViewModel: NSObject, ObservableObject {
    
    @Published var searchLoadStatus: SearchResultsLoadStatus = .loading
    @Published var search = ""
    
    @Published var reports = [Report]()
    
    func fetchReportsForSearch(override: Bool = false) async {
        if override {
            self.searchLoadStatus = .loading
            self.reports = []
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            Task {
                do {
                    var reports = [Report]()
                    reports = try await ReportManager.manager.fetchReports().textFilter(self.search).sorted(by: >)
                    
                    self.reports = reports
                    
                    guard !(reports.isEmpty) else {
                        self.searchLoadStatus = .empty
                        return
                    }
                    
                    self.searchLoadStatus = .loaded
                    
                } catch {
                    self.searchLoadStatus = .error
                }
            }
        }
    }
}
