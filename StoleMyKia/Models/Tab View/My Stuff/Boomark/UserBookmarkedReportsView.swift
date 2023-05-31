//
//  UserBookmarkedReportsView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 5/29/23.
//

import SwiftUI

struct UserBookmarkedReportsView: View {
    
    @State private var boomarkedReports = [Report]()
    @State private var selectedBookmarkReport: Report?
    
    @State private var alertErrorFetchingBookmarks = false
    
    @ObservedObject var userModel: UserViewModel
    @EnvironmentObject var reportsModel: ReportsViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                switch boomarkedReports.isEmpty {
                case true:
                    NoBookmarkView()
                case false:
                    list
                }
            }
        }
        .onAppear {
            userModel.setUserReportsDelegate(reportsModel)
            getBookmarkReports()
        }
    }
    
    var list: some View {
        VStack {
            ForEach(boomarkedReports) { report in
                ReportCellView(report: report)
                    .onTapGesture {
                        selectedBookmarkReport = report
                    }
            }
        }
    }
    
    private func getBookmarkReports() {
        userModel.getUserBookmarks { status in
            switch status {
            case .success(let reports):
                self.boomarkedReports = reports
                print(reports.count)
            case .failure(let error):
                print(error)
                self.alertErrorFetchingBookmarks.toggle()
            }
        }
    }
}

struct UserBookmarkedReportsView_Previews: PreviewProvider {
    static var previews: some View {
        UserBookmarkedReportsView(userModel: UserViewModel())
            .environmentObject(ReportsViewModel())
    }
}
