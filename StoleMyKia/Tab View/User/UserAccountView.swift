//
//  UserAccountView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/27/23.
//

import SwiftUI

struct UserAccountView: View {
    
    @State private var isShowingSettingsView = false
    
    @ObservedObject var loginModel: LoginViewModel
    
    @EnvironmentObject var notificationModel: NotificationViewModel
    @EnvironmentObject var reportsModel: ReportsViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingSettingsView.toggle()
                    } label: {
                       Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $isShowingSettingsView) {
                SettingsView()
                    .interactiveDismissDisabled()
            }
            .environmentObject(notificationModel)
            .environmentObject(loginModel)
            .environmentObject(reportsModel)
        }
    }
}

struct UserAccountView_Previews: PreviewProvider {
    static var previews: some View {
        UserAccountView(loginModel: LoginViewModel())
            .environmentObject(ReportsViewModel())
            .environmentObject(NotificationViewModel())
    }
}
