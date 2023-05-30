//
//  UserAccountView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/27/23.
//

import SwiftUI

enum UserAccountViewSelection: String, CaseIterable, Identifiable {
    
    case userReports = "My Reports"
    case updates     = "Updates"
    case bookmark    = "Boomarked"
    
    var id: Int {
        switch self {
        case .userReports:
            return 0
        case .updates:
            return 1
        case .bookmark:
            return 2
        }
    }
    
    var indicator: Image {
        switch self {
        case .userReports:
            return Image(systemName: "list.dash")
        case .updates:
            return Image(systemName: "arrow.uturn.backward")
        case .bookmark:
            return Image(systemName: "bookmark")
        }
    }
}

struct MyStuffView: View {
    
    @State private var userAccountTabViewSelection: UserAccountViewSelection = .userReports
    
    @State private var isShowingSettingsView = false
    
    @ObservedObject var userModel: UserViewModel
    
    @EnvironmentObject var notificationModel: NotificationViewModel
    @EnvironmentObject var reportsModel: ReportsViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                tabViewSelectionRow
                VStack {
                    TabView(selection: $userAccountTabViewSelection) {
                        UserReportsView(userModel: userModel)
                            .tag(UserAccountViewSelection.userReports)
                        UserUpdatesView()
                            .tag(UserAccountViewSelection.updates)
                        UserBookmarkedReportsView()
                            .tag(UserAccountViewSelection.bookmark)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingSettingsView.toggle()
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.brand)
                    }
                }
            }
            .onChange(of: userAccountTabViewSelection) { _ in
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            }
            .navigationTitle(userAccountTabViewSelection.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .environmentObject(reportsModel)
            .environmentObject(userModel)
            .sheet(isPresented: $isShowingSettingsView) {
                SettingsView()
                    .environmentObject(userModel)
                    .environmentObject(notificationModel)
                    .environmentObject(reportsModel)
            }
        }
    }
    
    var tabViewSelectionRow: some View {
        VStack {
            Divider()
            HStack {
                Spacer()
                ForEach(UserAccountViewSelection.allCases) { selection in
                    selection.indicator
                        .resizable()
                        .scaledToFit()
                        .frame(width: 23, height: 23)
                        .foregroundColor(userAccountTabViewSelection == selection ? .brand : .gray)
                        .onTapGesture {
                            changeSelection(selection)
                        }
                    Spacer()
                }
            }
            .frame(height: 10)
            .padding()
            Divider()
        }
    }
    
    private func changeSelection(_ selection: UserAccountViewSelection) {
        withAnimation {
            self.userAccountTabViewSelection = selection
        }
    }
}


struct UserAccView_Previews: PreviewProvider {
    static var previews: some View {
        MyStuffView(userModel: UserViewModel())
            .environmentObject(NotificationViewModel())
            .environmentObject(ReportsViewModel())
    }
}
