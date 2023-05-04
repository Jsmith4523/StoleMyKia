//
//  UserAccountView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/27/23.
//

import SwiftUI
import MapKit

struct UserAccountView: View {
    
    private enum AccountViewSelection: CaseIterable {
        case userReports
        //case favorites
        
        var icon: String {
            switch self {
            case .userReports:
                return "line.3.horizontal"
//            case .favorites:
//                return "bookmark.fill"
            }
        }
    }
    
    @State private var viewSelection: AccountViewSelection = .userReports
    
    @State private var isShowingSettingsView = false
    
    @ObservedObject var userModel: UserViewModel
    
    @EnvironmentObject var notificationModel: NotificationViewModel
    @EnvironmentObject var reportsModel: ReportsViewModel
    
    let imageCache = ImageCache()
    
    var body: some View {
        CustomNavView(title: "My Account", statusBarColor: .darkContent, backgroundColor: .brand) {
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 35)
                userHeader
                VStack(spacing: 0) {
                    //tabViewSelection
                    TabView(selection: $viewSelection) {
                        UserReportsView(userModel: userModel, imageCache: imageCache)
                            .tag(AccountViewSelection.userReports)
//                        Color.brand.ignoresSafeArea()
//                            .tag(AccountViewSelection.favorites)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingSettingsView.toggle()
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.white)
                    }
                }
            }
            .refreshable {
                
            }
        }
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            userModel.userReportsDelegate = reportsModel
        }
        .sheet(isPresented: $isShowingSettingsView) {
            SettingsView()
                .environmentObject(userModel)
                .environmentObject(notificationModel)
                .environmentObject(reportsModel)
        }
    }
    
    var userHeader: some View {
        VStack {
            HStack(alignment: .top) {
                Image.userPlaceholder
                    .resizable()
                    .scaledToFill()
                    .frame(width: 75, height: 75)
                    .clipShape(Circle())
                VStack(alignment: .leading) {
                    Text("Hello There!")
                        .font(.system(size: 30).weight(.heavy))
                    VStack(alignment: .leading) {
                        if let displayName = userModel.getUserDisplayName() {
                            Text("User \(displayName)")
                        }
                        if let date = userModel.getUserCreationDate() {
                            Text("Member since \(date.date)")
                        }
                    }
                    .font(.system(size: 17))
                    .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding()
            Divider()
        }
    }
    
    var tabViewSelection: some View {
        VStack {
            HStack {
                ForEach(AccountViewSelection.allCases, id: \.icon) { selection in
                    Spacer()
                    Image(systemName: selection.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 21, height: 21)
                        .foregroundColor(self.viewSelection == selection ? .brand : .gray)
                        .padding()
                        .onTapGesture {
                            setTabViewSelection(selection)
                        }
                    Spacer()
                }
            }
            .padding(.horizontal)
            Divider()
        }
    }
    
    private func setTabViewSelection(_ selection: AccountViewSelection) {
        UIImpactFeedbackGenerator().impactOccurred(intensity: 4)
        withAnimation {
            self.viewSelection = selection
        }
    }
}

fileprivate struct UserReportsView: View {
        
    @State private var isLoading = false
    @State private var didFailToFetchReports = false
    
    @State private var userReports = [Report]()
    
    @ObservedObject var userModel: UserViewModel
    
    let imageCache: ImageCache
    
    var body: some View {
        ZStack {
            switch isLoading {
            case true:
                ProgressView()
            case false:
                list
            }
        }
        .frame(maxHeight: .infinity)
        .onAppear {
            if userReports.isEmpty {
                fetchUserReports()
            }
        }
        .refreshable {
            fetchUserReports()
        }
    }
    
    var list: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                ForEach(userReports) { report in
                    UserReportCellView(report: report, imageCache: imageCache)
                }
                Spacer()
            }
        }
    }
    
    private func fetchUserReports() {
        if userReports.isEmpty {
            self.isLoading = true
        }
        
        userModel.getUserReports { results in
            switch results {
            case .success(let reports):
                self.userReports = reports
                self.isLoading = false
            case .failure(_):
                break
            }
        }
    }
    
    fileprivate struct UserReportCellView: View {
        
        @State private var isShowingReportDetailView = false
        
        @State private var vehicleImage: UIImage?
        
        let report: Report
        let imageCache: ImageCache
        
        @EnvironmentObject var reportsViewModel: ReportsViewModel
        
        var body: some View {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(report.type)
                                .font(.system(size: 30).weight(.heavy))
                            Text(report.vehicleDetails)
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        report.status.label
                    }
                    .padding()
                    ZStack {
                        ReportMap(report: report)
                            .frame(height: 175)
                        
                    }
                    Spacer()
                        .frame(height: 20)
                }
            }
            .onTapGesture {
                self.isShowingReportDetailView.toggle()
            }
            .sheet(isPresented: $isShowingReportDetailView) {
                SelectedReportDetailView(report: report, imageCache: imageCache)
            }
        }
    }
}

struct UserAccView_Previews: PreviewProvider {
    static var previews: some View {
        UserAccountView(userModel: UserViewModel())
            .environmentObject(NotificationViewModel())
            .environmentObject(ReportsViewModel())
    }
}
