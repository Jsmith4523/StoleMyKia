//
//  NotificationSettingsView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/13/23.
//

import SwiftUI

struct NotificationSettingsView: View {
    
    @State private var isShowingNotificationRadiusView = false
    
    @EnvironmentObject var reportsModel: ReportsViewModel
    @EnvironmentObject var notificationModel: NotificationViewModel

    var body: some View {
        VStack {
            Form {
                Section {
//                    Group {
//                        Toggle("Vehicle Stolen", isOn: $notificationModel.notifyOfTheft)
//                        Toggle("Theft Witnessed", isOn: $notificationModel.notifyOfWitness)
//                        Toggle("Vehicle found", isOn: $notificationModel.notifyOfFound)
//                    }
                } header: {
                    Text("Active Alerts")
                } footer: {
                    if !(notificationModel.notificationsAreAllowed) {
                        VStack {
                            Text("Notifications are disable as you've either denied or not enable them. Not enabling your location also affects notifications. \n\nYou can re-enable them in Settings > 'StoleMyKia'")
                        }
                    }
                }
                Section {
                    Button {
                        isShowingNotificationRadiusView.toggle()
                    } label: {
                        Text("Change Notification Radius")
                    }
                } header: {
                    Text("Alert Radius")
                } footer: {
                    Text("Change your notification radius of locations you would like to be notified on")
                }
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
//        .disabled(!notificationModel.notificationsAreAllowed && !reportsModel.locationAuthorizationStatus.isAuthorized())
        .tint(.accentColor)
        .sheet(isPresented: $isShowingNotificationRadiusView) {
            NotificationRadiusView()
        }
        .environmentObject(notificationModel)
    }
}

struct NotificationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NotificationSettingsView()
        }
        .environmentObject(NotificationViewModel())
        .environmentObject(ReportsViewModel())
    }
}
