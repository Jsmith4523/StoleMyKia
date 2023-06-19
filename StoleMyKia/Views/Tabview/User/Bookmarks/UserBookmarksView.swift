//
//  UserBookmarksView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/16/23.
//

import SwiftUI

struct UserBookmarksView: View {
    
    @State private var alertErrorGettingBookmarks = false
    
    @State private var reports = [Report]()
    
    @EnvironmentObject var userModel: UserViewModel
    @EnvironmentObject var reportsModel: ReportsViewModel
    
    var body: some View {
        ScrollView {
            switch reports.isEmpty {
            case true:
                noBookmarksView
            case false:
                list
            }
        }
        .refreshable {
            
        }
        .environmentObject(userModel)
        .environmentObject(reportsModel)
        .alert("That's an error", isPresented: $alertErrorGettingBookmarks) {
            Button("OK") {}
        } message: {
            Text("There was an issue gathering your bookmarks. Check your internet connection and try again.")
        }
    }
    
    private func getUserBookmarks() {
        userModel.getUserReports { result in
            switch result {
            case .success(let reports):
                self.reports = reports
            case .failure(_):
                self.alertErrorGettingBookmarks.toggle()
            }
        }
    }
    
    private var list: some View {
        ZStack {
            Color(uiColor: .secondarySystemBackground)
            VStack(spacing: 20) {
                ForEach(reports) { report in
                    NavigationLink {
                        SelectedReportDetailView(reportID: report.id)
                    } label: {
                        ReportCellView(report: report)
                    }
                }
            }
        }
    }
    
    var noBookmarksView: some View {
        VStack {
            Spacer()
                .frame(height: 135)
            VStack(spacing: 15) {
                Image(systemName: UserTabViewSelection.bookmarks.symbol)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 55, height: 55)
                Text("You don't have any bookmarked reports.")
                    .font(.system(size: 22).bold())
                Text("Start by bookmarking any reports you find interesting.")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal)
    }
}

struct UserBookmarksView_Previews: PreviewProvider {
    static var previews: some View {
        UserBookmarksView()
            .environmentObject(UserViewModel())
            .environmentObject(ReportsViewModel())
    }
}
