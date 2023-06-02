//
//  ContentView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/11/23.
//

import SwiftUI

struct Tab: View {
            
    @StateObject private var reportsModel = ReportsViewModel()
    @StateObject private var notificationModel = NotificationViewModel()
    
    @ObservedObject var userModel: UserViewModel
    
    var body: some View {
        TabView {
            ReportsMapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
            NotificationsView()
                .badge(100)
                .tabItem {
                    Label("Notifications", systemImage: "bell")
                }
            ResourcesView()
                .tabItem {
                    Label("Resources", systemImage: "books.vertical")
                }
            MyStuffView()
                .tabItem {
                    Label("My Stuff", systemImage: "archivebox")
                }
       }
        .sheet(item: $reportsModel.reportDetailMode) { mode in
            switch mode {
            case .multiple(let reports):
                MultipleReportsView(reports: reports)
                    .presentationDragIndicator(.visible)
            case .single(let report):
                SelectedReportDetailView(report: report)
                    .presentationDragIndicator(.visible)
            }
        }
        .onAppear {
            reportsModel.firebaseUserDelegate = userModel
        }
        .environmentObject(reportsModel)
        .environmentObject(notificationModel)
        .environmentObject(userModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Tab(userModel: UserViewModel())
            .environmentObject(NotificationViewModel())
            .environmentObject(UserViewModel())
    }
}
