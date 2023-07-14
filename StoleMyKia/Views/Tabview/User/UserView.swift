//
//  UserVew.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/10/23.
//

import SwiftUI

struct UserView: View {
    
    @State private var isShowingSettingsView = false
    
    @EnvironmentObject var userModel: UserViewModel
    @EnvironmentObject var reportsModel: ReportsViewModel
    
    @State private var tabViewSelection: UserTabViewSelection = .reports
    
    var body: some View {
        NavigationView {
            VStack {
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingSettingsView.toggle()
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            .customSheetView(isPresented: $isShowingSettingsView, detents: [.large()]) {
                SettingsView()
                    .environmentObject(userModel)
                    .environmentObject(reportsModel)
            }
            .environmentObject(userModel)
            .environmentObject(reportsModel)
        }
    }
}

struct UserVew_Previews: PreviewProvider {
    static var previews: some View {
        UserView()
            .environmentObject(ReportsViewModel())
            .environmentObject(UserViewModel())
    }
}
