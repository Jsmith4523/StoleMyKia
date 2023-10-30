//
//  UserReportsView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/3/23.
//

import SwiftUI

struct UserReportsView: View {
    
    @State private var reportsLoadStatus: UserReportsLoadStatus = .loading
    
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var reportsVM: ReportsViewModel
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                switch reportsLoadStatus {
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
            .navigationTitle(MyStuffView.MyStuffRoute.reports.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .refreshable {
                await fetchUserReports()
            }
            .task {
                await fetchUserReports()
            }
        }
    }
    
    private func fetchUserReports() async {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) {
            Task {
                self.reportsLoadStatus = await userVM.getUserReports()
            }
        }
    }
    
    private func reportDeleted() {
        self.reportsLoadStatus = .loading
        Task {
            await fetchUserReports()
        }
    }
}

struct UserReportsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UserReportsView()
                .tint(Color(uiColor: .label))
                .environmentObject(ReportsViewModel())
        }
    }
}
