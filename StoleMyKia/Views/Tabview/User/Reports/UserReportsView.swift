//
//  UserReportsView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/16/23.
//

import SwiftUI

struct UserReportsView: View {
    
    @EnvironmentObject var reportsModel: ReportsViewModel
    @EnvironmentObject var userModel: UserViewModel
    
    @State private var alertErrorGettingReports = false
    
    @State private var reports = [Report]()
    
    var body: some View {
        ScrollView {
            switch reports.isEmpty {
            case true:
                noUserReports
            case false:
                list
            }
        }
        .environmentObject(reportsModel)
        .refreshable {
            self.getUserReports()
        }
        .alert("That's an error!", isPresented: $alertErrorGettingReports) {
            Button("OK") {}
        } message: {
            Text("There was an issue gathering your reports. Please check your network and try again.")
        }
    }
    
    private var list: some View {
        VStack {
            ForEach(reports) { report in
//                NavigationLink {
//                    SelectedReportDetailView(reportID: report.id)
//                } label: {
//                    ReportCellView(report: report)
//                }
            }
        }
    }
    
    var noUserReports: some View {
        VStack {
            Spacer()
                .frame(height: 135)
            VStack(spacing: 15) {
                Image(systemName: UserTabViewSelection.reports.symbol)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 55, height: 55)
                Text("Any reports you make will appear here.")
                    .font(.system(size: 22).bold())
                Text("This includes any updates you have made to existing reports")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal)
    }
    
    
    private func getUserReports() {
        
    }
}

struct UserReportsView_Previews: PreviewProvider {
    static var previews: some View {
        UserReportsView().noUserReports
            .environmentObject(UserViewModel())
    }
}
