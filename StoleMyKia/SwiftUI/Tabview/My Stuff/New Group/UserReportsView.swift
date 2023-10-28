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
    
    var body: some View {
        NavigationView {
            ScrollView {
                switch reportsLoadStatus {
                case .loading:
                    
                case .loaded(let reports):
                    
                case .empty:
                    
                case .error:
                    
                }
            }
            .navigationTitle(MyStuffView.MyStuffRoute.reports.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        
                    }
                }
            }
            .refreshable {
                
            }
        }
    }
    
    private func fetchUserReports() async {
        self.reportsLoadStatus = await userVM.getUserReports()
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
