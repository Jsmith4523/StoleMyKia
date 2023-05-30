//
//  ContentView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/11/23.
//

import SwiftUI

struct Tab: View {
    
    @State private var selection: TabSelection = .map
    
    @StateObject private var reportsModel = ReportsViewModel()
    @StateObject private var notificationModel = NotificationViewModel()
    @StateObject private var userModel = UserViewModel()
    
    enum TabSelection {
        case map, notification, myStuff
    }
    
    
    var body: some View {
        TabView(selection: $selection) {
            ReportsMapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
                .tag(TabSelection.map)
            NotificationsView()
                .tabItem {
                    Label("Notifications", systemImage: "bell")
                }
                .tag(TabSelection.notification)
            MyStuffView(userModel: userModel)
                .tabItem {
                    Label("My Stuff", systemImage: "archivebox")
                }
                .tag(TabSelection.myStuff)

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
