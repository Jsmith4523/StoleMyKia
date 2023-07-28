//
//  NotificationListView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 7/13/23.
//

import SwiftUI

struct NotificationListView: View {
    
    @State private var firebaseNotification: FirebaseNotification?
    
    @EnvironmentObject var notificationVM: NotificationViewModel
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var reportsVM: ReportsViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(notificationVM.userNotifications.sorted(by: >)) { notification in
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        firebaseNotification = notification
                    } label: {
                        FirebaseNotificationReportCellView(notification: notification)
                    }
                    Divider()
                }
            }
        }
        .refreshable {
            notificationVM.fetchFirebaseUserNotifications()
        }
        .environmentObject(notificationVM)
        .environmentObject(userVM)
        .environmentObject(reportsVM)
        .sheet(item: $firebaseNotification) { notification in
            switch notification.notificationType {
            case .notification:
                SelectedReportDetailView(report: notification.report)
                    .environmentObject(userVM)
                    .environmentObject(reportsVM)
            case .update:
                TimelineMapView(report: notification.report)
                    .environmentObject(userVM)
                    .environmentObject(reportsVM)
            }
        }
    }
}

fileprivate struct FirebaseNotificationReportCellView: View {
    
    @State private var vehicleImage: UIImage?
    
    let notification: FirebaseNotification
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Label(notification.report.reportType.rawValue, systemImage: notification.notificationType.symbol)
                        .font(.system(size: 12).weight(.heavy))
                        .padding(3)
                        .foregroundColor(.white)
                        .background(Color(uiColor: notification.report.reportType.annotationColor).opacity(0.75))
                        .cornerRadius(5)
                    Spacer()
                    Text(notification.report.dt.full)
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                Text(notification.report.vehicleDetails)
                    .font(.system(size: 15).weight(.heavy))
                VStack(alignment: .leading) {
                    Text(notification.report.reportType.generateNotificationBody(for: notification.report.vehicle))
                        .font(.system(size: 12))
                }
            }
            Spacer()
        }
        .padding()
        .foregroundColor(notification.isRead ? .gray : Color(uiColor: .label))
        .multilineTextAlignment(.leading)
        .onAppear {
            getVehicleImage()
        }
    }
    
    private func getVehicleImage() {
        guard let imageUrl = notification.report.imageURL else { return }
        
        ImageCache.shared.getImage(imageUrl) { image in
            self.vehicleImage = image
        }
    }
}

struct NotificationListView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationListView()
            .environmentObject(NotificationViewModel())
            .environmentObject(UserViewModel())
            .environmentObject(ReportsViewModel())
    }
}
