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
        ScrollView {
            switch bookmarksLoadStatus {
            case .loading:
                UserReportsSkeletonView()
            case .loaded(let reports):
                UserReportsListView(reports: reports, deleteCompletion: reportDeleted)
                    .environmentObject(userVM)
                    .environmentObject(reportsVM)
            case .empty:
                MyStuffUserReportsEmptyView(selection: .bookmarks)
            case .error:
                ErrorView()
            }
        }
        .navigationTitle(MyStuffView.MyStuffRoute.bookmarks.title)
        .task {
            await fetchUserBookmarks()
        }
        .refreshable {
            await fetchUserBookmarks()
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
