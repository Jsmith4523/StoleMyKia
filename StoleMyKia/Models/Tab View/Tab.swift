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
        FeedView(reportModel: reportsModel)
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
