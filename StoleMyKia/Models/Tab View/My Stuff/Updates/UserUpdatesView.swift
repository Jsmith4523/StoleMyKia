//
//  UserUpdatesView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 5/29/23.
//

import SwiftUI

struct UserUpdatesView: View {
    
    @State private var alertErrorFetching = false
    
    @State private var updateReports = [Report]()
    
    @EnvironmentObject var userModel: UserViewModel
    @EnvironmentObject var reportsModel: ReportsViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                switch updateReports.isEmpty {
                case true:
                    NoUpdatesView()
                case false:
                    list
                }
            }
        }
        .onAppear {
            getUserUpdates()
        }
    }
    
    var list: some View {
        ForEach(updateReports) { report in
            NavigationLink {
                
            } label: {
                ReportCellView(report: report)
            }
        }
    }
    
    private func getUserUpdates() {
        userModel.getUserUpdates { status in
            switch status {
            case .success(let reports):
                self.updateReports = reports
            case .failure(let error):
                alertErrorFetching.toggle()
                print(error.description)
            }
        }
    }
}
