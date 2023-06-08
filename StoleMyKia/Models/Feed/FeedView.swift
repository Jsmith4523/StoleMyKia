//
//  FeedView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/7/23.
//

import Foundation
import SwiftUI

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
    
    @State private var detailSelection: FeedDetailPicker = .feed
        
    @StateObject private var reportsModel = ReportsViewModel()
    @StateObject private var notificationModel = NotificationViewModel()
    
    @EnvironmentObject private var userModel: UserViewModel
     
    var body: some View {
        CustomNavView(statusBarColor: .lightContent, backgroundColor: .brand) {
            ZStack {
                TabView(selection: $detailSelection) {
                    Color.red
                        .tag(FeedDetailPicker.feed)
                        .edgesIgnoringSafeArea(.bottom)
                    MKMapViewRepresentable()
                        .tag(FeedDetailPicker.map)
                        .edgesIgnoringSafeArea(.bottom)
                }
                Button("Sign out") {
                    userModel.signOut { _ in
                        
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink {
                        MyStuffView()
                            .environmentObject(userModel)
                            .environmentObject(reportsModel)
                            .environmentObject(NotificationViewModel())
                    } label: {
                        Image(systemName: "person.circle")
                            .foregroundColor(.white)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Picker("", selection: $detailSelection) {
                        ForEach(FeedDetailPicker.allCases) { selection in
                            Text(selection.title)
                                .tag(selection)
                        }
                    }
                    .frame(width: 125)
                    .pickerStyle(.segmented)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    
                }
            }
        }
        .ignoresSafeArea()
    }
}
