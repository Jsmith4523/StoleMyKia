//
//  UserBookmarksView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/15/23.
//

import SwiftUI

struct UserBookmarksView: View {
    
    @State private var bookmarksLoadStatus: UserReportsLoadStatus = .loading
    
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var reportsVM: ReportsViewModel
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                switch bookmarksLoadStatus {
                case .loading:
                    UserReportsSkeletonView()
                case .loaded(let reports):
                    UserReportsListView(reports: reports, deleteCompletion: reportDeleted)
                        .environmentObject(userVM)
                        .environmentObject(reportsVM)
                case .empty:
                    ReportsEmptyView()
                case .error:
                    ErrorView()
                }
            }
            .navigationTitle(MyStuffView.MyStuffRoute.bookmarks.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .task {
                await fetchUserBookmarks()
            }
            .refreshable {
                await fetchUserBookmarks()
            }
        }
    }
    
    private func fetchUserBookmarks() async {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) {
            Task {
                self.bookmarksLoadStatus = await userVM.getUserBookmarks()
            }
        }
    }
    
    private func reportDeleted() {
        self.bookmarksLoadStatus = .loading
        Task {
            await fetchUserBookmarks()
        }
    }
}

//#Preview {
//    UserBookmarksView()
//}
