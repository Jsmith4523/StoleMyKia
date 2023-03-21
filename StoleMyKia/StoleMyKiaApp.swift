//
//  StoleMyKiaApp.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/11/23.
//

import SwiftUI
import Firebase

@main
struct StoleMyKiaApp: App {
    
    @StateObject private var notificationModel = NotificationViewModel()
    @StateObject private var reportsModel = ReportsViewModel()
    
    @UIApplicationDelegateAdaptor (AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            Tab()
                .sheet(isPresented: $reportsModel.isShowingSelectedReportView) {
                    SelectedReportDetailView()
                }
                .environmentObject(reportsModel)
                .environmentObject(notificationModel)
                .onAppear {
                    reportsModel.upload(.init(title: "Lorem Ipsum", description: "This is dummy text", reportType: .found, vehicleYear: 2012, vehicleMake: .hyundai, vehicleColor: .black, vehicleModel: .tuscon, lat: 32.4332, lon: -84.2343))
                }
        }
    }
}


class AppDelegate: UIScene, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
}
