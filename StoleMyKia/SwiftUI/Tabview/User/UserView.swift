//
//  UserVew.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/10/23.
//

import SwiftUI

struct UserView: View {
        
    @EnvironmentObject var userModel: UserViewModel
    @EnvironmentObject var reportsModel: ReportsViewModel
    
    @State private var tabViewSelection: UserTabViewSelection = .reports
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                UserViewTabSelectionView(selection: $tabViewSelection)
                TabView(selection: $tabViewSelection) {
                    UserReportsView()
                        .tag(UserTabViewSelection.reports)
                    UserBookmarksView()
                        .tag(UserTabViewSelection.bookmarks)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle(ApplicationTabViewSelection.user.title)
            .navigationBarTitleDisplayMode(.inline)
            .environmentObject(userModel)
            .environmentObject(reportsModel)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        SettingsView()
                            .environmentObject(userModel)
                            .environmentObject(reportsModel)
                    } label: {
                        Image(systemName: "line.3.horizontal")
                    }
                }
            }
        }
        .tint(Color(uiColor: .label))
    }
}

struct UserVew_Previews: PreviewProvider {
    static var previews: some View {
        UserView()
            .environmentObject(ReportsViewModel())
            .environmentObject(UserViewModel())
    }
}
