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
    @EnvironmentObject var loginModel: LoginViewModel
    
    private let imageCache = ImageCache()

    var body: some View {
        TabView {
            MapView(imageCache: imageCache)
                .tabItem {
                    Label("Reports", systemImage: "car.2.fill")
                }
            NotificationsView()
                .tabItem {
                    Label("Notifications", systemImage: "bell")
                }
            UserAccountView(loginModel: loginModel)
                .tabItem {
                    Label("Account", systemImage: "person")
                }
        }
        .accentColor(.accentColor)
        .reportDetailView(isPresented: $reportsModel.isShowingSelectedReportView, cache: imageCache, report: reportsModel.selectedReport)
        .environmentObject(reportsModel)
        .environmentObject(notificationModel)
        .environmentObject(loginModel)
        .onAppear {
            reportsModel.firebaseUserDelegate = loginModel
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Tab()
            .environmentObject(NotificationViewModel())
            .environmentObject(LoginViewModel())
    }
}
