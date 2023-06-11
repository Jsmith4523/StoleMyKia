//
//  ApplicationTabView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/10/23.
//

import SwiftUI

struct ApplicationTabView: View {
    
    @StateObject private var reportsVM = ReportsViewModel()
    @EnvironmentObject var userModel: UserViewModel
        
    var body: some View {
        TabView {
            FeedView()
                .tabItem {
                    Label("Feed", systemImage: "square.stack.3d.down.right")
                }
            NotificationView()
                .badge(94)
                .tabItem {
                    Label("Notifications", systemImage: "bell")
                }
            UserView()
                .tabItem {
                    Label("Account", systemImage: "person.crop.circle")
                }
        }
        .environmentObject(reportsVM)
        .environmentObject(userModel)
        .tint(Color(uiColor: .label))
    }
}

struct ApplicationTabView_Previews: PreviewProvider {
    static var previews: some View {
        ApplicationTabView()
            .environmentObject(ReportsViewModel())
            .environmentObject(UserViewModel())
            .preferredColorScheme(.dark)
    }
}
