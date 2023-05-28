//
//  ContentView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/11/23.
//

import SwiftUI

struct Tab: View {
    
    @StateObject private var reportsModel = ReportsViewModel()
    
    @EnvironmentObject var notificationModel: NotificationViewModel
    @EnvironmentObject var userModel: UserViewModel
    
    var body: some View {
        TabView {
            ReportsMapView()
                .tabItem {
                    Label("Reports", systemImage: "car.2.fill")
                }
            NotificationsView()
                .tabItem {
                    Label("Notifications", systemImage: "bell")
                }
            UserAccountView(userModel: userModel)
                .tabItem {
                    Label("Account", systemImage: "person")
                }
        }
        .sheet(item: $reportsModel.reportDetailMode) { mode in
            switch mode {
            case .multiple(let reports):
                MultipleReportsView(reports: reports)
            case .single(let report):
                SelectedReportDetailView(report: report)
            }
        }
        .environmentObject(reportsModel)
        .environmentObject(notificationModel)
        .environmentObject(userModel)
        .onAppear {
            reportsModel.firebaseUserDelegate = userModel
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Tab()
            .environmentObject(NotificationViewModel())
            .environmentObject(UserViewModel())
    }
}
