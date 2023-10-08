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
            ForEach(notificationVM.notifications) { notification in
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
    }
}

fileprivate struct NotificationCellView: View {
    
    @State private var vehicleImage: UIImage?
    
    let notification: AppUserNotification
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(notification.title)
                            .font(.system(size: 15.5).bold())
                    }
                    Text(notification.body)
                        .font(.system(size: 14))
                }
                Spacer()
                    .frame(height: 10)
                Text(notification.dateAndTime)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            Spacer()
            if notification.hasImage {
                imageView
            }
        }
        .padding()
        .background(!(notification.isRead) ? .blue.opacity(0.15) : .clear)
    }
    
    var imageView: some View {
        Image(uiImage: vehicleImage ?? .vehiclePlaceholder)
            .resizable()
            .scaledToFill()
            .frame(width: 70, height: 70)
            .clipShape(RoundedRectangle(cornerRadius: 2))
            .redacted(reason: vehicleImage.isNil() ? .placeholder : [])
            .onAppear {
                getVehicleImage()
            }
    }
    
    private func getVehicleImage() {
        ImageCache.shared.getImage(notification.imageUrl) { image in
            withAnimation {
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
//
//struct NotificationListView_Previews: PreviewProvider {
//    static var previews: some View {
//        NotificationCellView(notification: .init(id: UUID(), dt: Date.now.addingTimeInterval(-86400).epoch, title: "Update: Stolen", body: "An Update is available to your report regarding the Red 2020 Hyundai Elantra", notificationType: .report, reportId: UUID(), isRead: false, imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT0GcDq4DYvOB86BmsxrxCp18U8T2ckXPBBqw&usqp=CAU"))
//    }
//}
