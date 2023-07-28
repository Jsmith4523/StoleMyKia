//
//  UserNotificationSettings.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/19/23.
//

import SwiftUI

struct UserNotificationSettings: View {
    
    @State private var isShowingNotificationRadiusView = false
    
    @State private var enableCarjackReports = false
    @State private var enableStolenReports = false
    @State private var enableFoundReports = false
    @State private var enableWitnessReports = false
    @State private var enableSpottedReports = false
    
    @EnvironmentObject var userModel: UserViewModel
    
    var body: some View {
        Form {
            Section {
                Toggle("Car Jacks", isOn: $enableCarjackReports)
                Toggle("Stolen", isOn: $enableStolenReports)
                Toggle("Witnessed", isOn: $enableWitnessReports)
                Toggle("Found", isOn: $enableFoundReports)
                Toggle("Spotted", isOn: $enableSpottedReports)
            } header: {
                Text("Reports")
            } footer: {
                Text("Choose what reports you would like to be notified of. These settings work with your notification radius. They do not apply to reports you have made.")
            }
            .tint(.blue)
            
            Section {
                Button("Change Radius") {
                    isShowingNotificationRadiusView.toggle()
                }
            } header: {
                Text("Radius")
            } footer: {
                Text("Change your notification radius. Your notification radius allows you to filter out any reports that are out-of-bounds of location.")
            }
        }
        .navigationTitle("Notifications")
        .sheet(isPresented: $isShowingNotificationRadiusView) {
            NotificationRadiusView()
                .environmentObject(userModel)
                .interactiveDismissDisabled()
        }
    }
}

struct UserNotificationSettings_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UserNotificationSettings()
                .environmentObject(UserViewModel())
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
