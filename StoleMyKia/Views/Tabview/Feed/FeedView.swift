//
//  FeedView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/10/23.
//

import SwiftUI

struct FeedView: View {
    
    @State private var isShowingNewReportView = false
    @State private var reports = [Report]()
    
    @EnvironmentObject var userModel: UserViewModel
    @EnvironmentObject var reportsVM: ReportsViewModel
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                ScrollView {
                    switch reports.isEmpty {
                    case true:
                        NoReportsAvaliableView()
                    case false:
                        FeedListView(reports: $reports)
                    }
                }
            }
            .environmentObject(userModel)
            .environmentObject(reportsVM)
            .navigationTitle(ApplicationTabViewSelection.feed.title)
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                reportsVM.getReports()
            }
            .onAppear {
                reportsVM.getReports()
            }
            .onReceive(reportsVM.$reports) { reports in
                self.reports = reports
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ///Hides navigation title
                    Text("")
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Text(ApplicationTabViewSelection.feed.title)
                        .font(.system(size: 24).weight(.heavy))
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    NavigationLink {
                        FeedSearchView(reports: $reports)
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .bold()
                    }
//                    Button {
//                        reportsVM.isShowingLicensePlateScannerView.toggle()
//                    } label: {
//                        Image(systemName: "map")
//                            .bold()
//                    }
                    Button {
                        reportsVM.isShowingLicensePlateScannerView.toggle()
                    } label: {
                        Image(systemName: "camera")
                            .bold()
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingNewReportView) {
            NewReportView()
                .tint(.brand)
        }
        .fullScreenCover(isPresented: $reportsVM.isShowingLicensePlateScannerView) {
            LicensePlateScannerView()
        }
        .environmentObject(reportsVM)
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
            .environmentObject(UserViewModel())
            .environmentObject(ReportsViewModel())
            .tint(Color(uiColor: .label))
    }
}
