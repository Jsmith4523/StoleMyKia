//
//  StoleMyKiaApp.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/11/23.
//

import SwiftUI

@main
struct StoleMyKiaApp: App {
    
    @StateObject private var notificationModel = NotificationViewModel()
    @StateObject private var reportsModel = ReportsViewModel()
    
    var body: some Scene {
        WindowGroup {
            Tab()
                .sheet(isPresented: $reportsModel.isShowingSelectedReportView) {
                    SelectedReportDetailView()
                }
                .environmentObject(reportsModel)
                .environmentObject(notificationModel)
        }
    }
}
