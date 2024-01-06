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
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(notification.title)
                                .font(.system(size: 15).bold())
                        }
                        HStack {
                            Text(notification.body)
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                    }
                    Spacer()
                    if notification.hasImage {
                        imageView
                    }
                }
                
                HStack(alignment: .center) {
                    if !notification.isRead {
                        Circle()
                            .foregroundColor(.red)
                            .frame(width: 8, height: 8)
                    }
                    HStack(spacing: 5) {
                        Image(systemName: notification.notificationType.symbol)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                        Text(notification.dateAndTime)
                            .font(.system(size: 13))
                    }
                    Spacer()
                    Menu {
                        Button(role: .destructive) {
                            notificationVM.deleteNotification(notification)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 15, height: 15)
                            .padding(.horizontal, 4)
                    }
                }
                .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .multilineTextAlignment(.leading)
    }
    
    var imageView: some View {
        Image(uiImage: vehicleImage ?? .vehiclePlaceholder)
            .resizable()
            .scaledToFill()
            .frame(width: 70, height: 70)
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
        ImageCache.shared.getImage(notification.imageUrl) { image in
            DispatchQueue.main.async {
                self.vehicleImage = image
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
        NotificationCellView(notification: .init(id: "", dt: Date.now.addingTimeInterval(-86400*9).epoch, title: "Stolen - 2017 Hyundai Elanta", body: "The 2020 Red Hyundai Elantra report has received an update.", notificationType: .report, isRead: false, reportId: UUID(), imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT0GcDq4DYvOB86BmsxrxCp18U8T2ckXPBBqw&usqp=CAU"))
    }
}
