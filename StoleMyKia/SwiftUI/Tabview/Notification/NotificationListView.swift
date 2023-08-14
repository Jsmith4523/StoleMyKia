//
//  NotificationListView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 8/12/23.
//

import SwiftUI

struct NotificationListView: View {
    
    @State private var reportId: UUID?
    
    @State private var presentNotificationsActionSheet = false
    
    @EnvironmentObject var notificationVM: NotificationViewModel
    @EnvironmentObject var reportsVM: ReportsViewModel
    @EnvironmentObject var userVM: UserViewModel
    
    var body: some View {
        List {
            ForEach(notificationVM.notifications) { notification in
                Button {
                    self.reportId = notification.reportId
                } label: {
                    NotificationCellView(notification: notification)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)
                        }
                }
            }
        }
        .listStyle(.plain)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    presentNotificationsActionSheet.toggle()
                } label: {
                    Image(systemName: "gearshape")
                }
            }
        }
        .confirmationDialog("", isPresented: $presentNotificationsActionSheet) {
            Button("Mark All Read") {
                
            }
            Button("Delete All", role: .destructive) {
                
            }
        } message: {
            Text("Notification Options")
        }
        .sheet(item: $reportId) { id in
            TimelineMapView(detailMode: .reportId(id))
        }
    }
}

fileprivate struct NotificationCellView: View {
    
    @State private var presentDeleteNotificationAlert = false
    @State private var vehicleImage: UIImage?
    
    let notification: Notification
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                VStack(alignment: .leading, spacing: 7) {
                    HStack(spacing: 4) {
                        if !(notification.isRead) {
                            Circle()
                                .frame(width: 6, height: 6)
                                .foregroundColor(.blue)
                        }
                        HStack(spacing: 2) {
                            Image.updateImageIcon
                            Text(notification.reportType.rawValue)
                        }
                    }
                    .font(.system(size: 16).weight(.heavy))
                    Text(notification.body)
                        .font(.system(size: 13))
                }
            }
            Spacer()
            if notification.hasImage {
                Image(uiImage: vehicleImage ?? .vehiclePlaceholder)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 75, height: 75)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(4)
        .multilineTextAlignment(.leading)
        .foregroundColor(Color(uiColor: .label))
        .onAppear {
            getVehicleImage()
        }
        .alert("Delete Notification?", isPresented: $presentDeleteNotificationAlert) {
            Button("Delete", role: .destructive) {
                
            }
        }
    }
    
    private func getVehicleImage() {
        guard let imageUrl = notification.imageUrl else {
            return
        }
        
        ImageCache.shared.getImage(imageUrl) { image in
            self.vehicleImage = image
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
        NavigationView {
            NotificationListView()
                .environmentObject(NotificationViewModel())
                .environmentObject(ReportsViewModel())
                .environmentObject(UserViewModel())
                .navigationTitle("Notifications")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
