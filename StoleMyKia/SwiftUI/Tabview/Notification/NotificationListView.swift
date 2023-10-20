//
//  NotificationListView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 8/12/23.
//

import SwiftUI

struct NotificationListView: View {
    
    @State private var notification: AppUserNotification?
            
    @EnvironmentObject var notificationVM: NotificationViewModel
    @EnvironmentObject var reportsVM: ReportsViewModel
    @EnvironmentObject var userVM: UserViewModel
    
    var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(notificationVM.notifications.sorted(by: >)) { notification in
                NotificationCellView(notification: notification)
                    .onTapGesture {
                        notificationVM.userDidReadNotification(notification.id)
                    }
                Divider()
            }
        }
        .environmentObject(notificationVM)
        .environmentObject(userVM)
        .environmentObject(reportsVM)
        .fullScreenCover(item: $notification) { notification in
            
        }
    }
}

fileprivate struct NotificationCellView: View {
    
    @State private var vehicleImage: UIImage?
    
    let notification: AppUserNotification
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack {
                    if !notification.isRead {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 10, height: 10)
                    }
                    Image(systemName: notification.notificationType.symbol)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                }
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                Text(notification.title)
                                    .font(.system(size: 13).weight(.heavy))
                                    .lineLimit(2)
                            }
                            Text(notification.body)
                                .font(.system(size: 13.5))
                                .foregroundColor(.gray)
                                .lineLimit(3)
                            Text(notification.dateAndTime)
                                .font(.system(size: 12.5))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        if notification.hasImage {
                            imageView
                        }
                    }
                }
                Spacer()
            }
        }
        .padding()
        .multilineTextAlignment(.leading)
    }
    
    var imageView: some View {
        Image(uiImage: vehicleImage ?? .vehiclePlaceholder)
            .resizable()
            .scaledToFill()
            .frame(width: 70, height: 70)
            .clipped()
            .redacted(reason: vehicleImage.isNil() ? .placeholder : [])
            .onAppear {
                getVehicleImage()
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
