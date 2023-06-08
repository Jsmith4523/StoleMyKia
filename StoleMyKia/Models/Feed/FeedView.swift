//
//  FeedView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/7/23.
//

import Foundation
import SwiftUI
import PartialSheet

struct FeedView: View {
    
    enum FeedDetailPicker: Identifiable, CaseIterable, Hashable {
        case feed, map
        
        var id: String {
            self.title
        }
        
        var title: String {
            switch self {
            case .map:
                return "Map"
            case .feed:
                return "Feed"
            }
        }
    }
    
    @State private var isPresented = false
    
    @State private var detailSelection: FeedDetailPicker = .feed
    
    @StateObject private var reportsModel = ReportsViewModel()
    @StateObject private var notificationModel = NotificationViewModel()
    
    @EnvironmentObject private var userModel: UserViewModel
    
    var body: some View {
        NavigationView {
            //TabView {
                ZStack(alignment: .bottom) {
                    ZStack(alignment: .top) {
                        MKMapViewRepresentable()
                            .tag(FeedDetailPicker.map)
                            .ignoresSafeArea()
                        MapNavigationBar()
                    }
                    MapTabBar()
                //}
            }
        }
        .environmentObject(userModel)
        .environmentObject(reportsModel)
        .environmentObject(NotificationViewModel())
    }
}


struct Some_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
            .environmentObject(UserViewModel())
            .environmentObject(ReportsViewModel())
    }
}
