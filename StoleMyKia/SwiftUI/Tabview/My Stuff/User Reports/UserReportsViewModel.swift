//
//  UserReportsViewModel.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/3/23.
//

import Foundation

@MainActor
final class UserReportsViewModel: ObservableObject {
    
    enum LoadStatus {
        case loading, loaded, empty, error
    }
    
    @Published private(set) var reports = [Report]()
    @Published private(set) var reportsLoadStatus: LoadStatus = .loading
    
    @Published private(set) var bookmarks = [Report]()
    @Published private(set) var bookmarkLoadStatus: LoadStatus = .loading
    
    private let manager = UserReportsManager()
    
    init() {
        self.fetchInformation()
    }
    
    private func fetchInformation() {
        Task {
            try? await fetchUserReports()
            try? await fetchUserBookmarks()
        }
    }
        
    func fetchUserReports() async throws {
        do {
            let reports = try await manager.fetchUserReports()
            
            guard !(reports.isEmpty) else {
                self.reports = []
                self.reportsLoadStatus = .empty
                return
            }
            
            self.reports = reports
            self.reportsLoadStatus = .loaded
        } catch {
            self.reportsLoadStatus = .error
        }
    }
    
    func fetchUserBookmarks() async throws {
        do {
            let bookmarks = try await manager.fetchUserBookmarks()
            
            guard !(reports.isEmpty) else {
                self.bookmarks = []
                self.reportsLoadStatus = .empty
                return
            }
            
            self.bookmarks = bookmarks
            self.reportsLoadStatus = .loaded
        } catch {
            self.bookmarkLoadStatus = .error
        }
    }
}
