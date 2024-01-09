//
//  NotificationListView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 8/12/23.
//

import SwiftUI

struct NotificationListView: View {
                
    @EnvironmentObject var notificationVM: NotificationViewModel
    @EnvironmentObject var reportsVM: ReportsViewModel
    @EnvironmentObject var userVM: UserViewModel
    
    var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(notificationVM.notifications.sorted(by: >)) { notification in
                NotificationCellView(notification: notification)
                    .onTapGesture {
                        notificationVM.userDidReadNotification(notification)
                    }
                    .onAppear {
                        notificationVM.fetchMoreNotifications(after: notification)
                    }
                Divider()
            }
        }
        .environmentObject(notificationVM)
        .environmentObject(userVM)
        .environmentObject(reportsVM)
        .fullScreenCover(item: $notificationVM.notification) { notification in
            switch notification.notificationType {
            case .report:
                ReportDetailView(reportId: notification.reportId!)
                    .environmentObject(reportsVM)
            case .update:
                TimelineMapView(reportAssociatedId: notification.reportId!, dismissStyle: .dismiss)
            case .falseReport:
                FalseReportDetailView(reportId: notification.reportId!)
            }
        }
    }
}

fileprivate struct NotificationCellView: View {
        
    @State private var vehicleImage: UIImage?
    
    let notification: AppUserNotification
    
    @EnvironmentObject var notificationVM: NotificationViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 7) {
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 5) {
                            Text(notification.title)
                                .font(.system(size: 16).weight(.bold))
                                .lineLimit(2)
                        }
                        VStack {
                            Text(notification.body)
                                .font(.system(size: 14))
                                .lineLimit(4)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .frame(height: 65)
                    }
                    Spacer()
                    if notification.hasImage {
                        imageView
                    }
                }
                
                HStack(alignment: .center, spacing: 5) {
                    if !(notification.isRead) {
                        Circle()
                            .foregroundColor(.red)
                            .frame(width: 8, height: 8)
                    }
                    Image(systemName: notification.notificationType.symbol)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14.5, height: 14.5)
                    Text(notification.dateAndTime)
                        .font(.system(size: 13))
                    Spacer()
                }
                .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .multilineTextAlignment(.leading)
        .background(notification.isRead ? Color(uiColor: .systemBackground) : Color(uiColor: .secondarySystemBackground).opacity(0.35))
        .contextMenu {
            Button("Delete", role: .destructive) {
                notificationVM.deleteNotification(notification)
            }
        }
    }
    
    var imageView: some View {
        Image(uiImage: vehicleImage ?? .vehiclePlaceholder)
            .resizable()
            .scaledToFill()
            .frame(width: 82, height: 82)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .redacted(reason: vehicleImage.isNil() ? .placeholder : [])
            .onAppear {
                getVehicleImage()
            }
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            }
    }
    
    func getVehicleImage() {
        ImageCache.shared.getImage(notification.imageURL) { image in
            DispatchQueue.main.async {
                self.vehicleImage = image ?? .vehiclePlaceholder
            }
        }
    }
}

extension UUID: Identifiable {
    public var id: Self {
        return self
    }
}

struct NotificationListView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            NotificationCellView(notification: .init(id: "", dt: Date.now.addingTimeInterval(-86400*9).epoch, title: "Incident: Light Gray 2017 Hyundai Elantra", body: "Someone has taken my car on a joyride through the city. Need help locating it please thank you", notificationType: .report, isRead: false, reportId: UUID(), imageURL: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT0GcDq4DYvOB86BmsxrxCp18U8T2ckXPBBqw&usqp=CAU"))
        }
        .preferredColorScheme(.dark)
    }
}
