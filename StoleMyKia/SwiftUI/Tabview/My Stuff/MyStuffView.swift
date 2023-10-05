//
//  MyStuffView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 9/19/23.
//

import SwiftUI

struct MyStuffView: View {
    
    enum MyStuffRoute: CaseIterable, Identifiable {
        case reports, bookmarks
        
        var id: Self {
            return self
        }
        
        var title: String {
            switch self {
            case .bookmarks:
                return "Bookmarks"
            case .reports:
                return "Reports"
            }
        }
        
        var symbol: String {
            switch self {
            case .bookmarks:
                return "bookmark"
            case.reports:
                return ApplicationTabViewSelection.feed.symbol
            }
        }
    }
    
    @State private var alertSignOut = false
    @State private var isShowingSettingsView = false
    
    @StateObject private var userReportsVM = UserReportsViewModel()
        
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var reportsVM: ReportsViewModel
        
    var body: some View {
        NavigationController(title: ApplicationTabViewSelection.myStuff.title, statusBarColor: .lightContent, backgroundColor: .brand) {
            ScrollView {
                VStack(spacing: 0) {
                    header
                    buttons
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("")
                }
            }
        }
        .ignoresSafeArea()
        .accentColor(.white)
        .tint(.white)
        .alert("Sign Out", isPresented: $alertSignOut) {
            Button("Cancel") {}
            Button("Yes") {
                userVM.signOut()
            }
        } message: {
            Text("You'll be signed out of \(userVM.getAuthUserPhoneNumber() ?? "the application"). Are you sure?")
        }
    }
    
    var header: some View {
        ZStack {
            GeometryReader { proxy in
                Color.brand
                    .offset(y: -proxy.frame(in: .global).minY)
                    .frame(height: proxy.frame(in: .global).minY + 125)
            }
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Hello")
                        .font(.system(size: 40).weight(.heavy))
                    Text(userVM.getAuthUserPhoneNumber() ?? "")
                        .font(.system(size: 25))
                }
                Spacer()
            }
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
        }
        .frame(height: 125)
        .customSheetView(isPresented: $isShowingSettingsView, detents: [.large()], showsIndicator: true, cornerRadius: 25) {
            SettingsView()
                .environmentObject(userVM)
        }
    }
    
    var buttons: some View {
        ZStack {
            VStack {
                VStack(spacing: 15) {
                    VStack(spacing: 0) {
                        ForEach(MyStuffRoute.allCases) { route in
                            Divider()
                            NavigationLink {
                                ZStack {
                                    switch route {
                                    case .reports:
                                        UserReportsView()
                                            .environmentObject(userVM)
                                            .environmentObject(userReportsVM)
                                            .environmentObject(reportsVM)
                                    case .bookmarks:
                                        EmptyView()
                                            .environmentObject(userVM)
                                            .environmentObject(userReportsVM)
                                            .environmentObject(reportsVM)
                                    }
                                }
                                .toolbar {
                                    ToolbarItem(placement: .principal) {
                                        Text(route.title)
                                            .font(.system(size: 15).weight(.medium))
                                            .foregroundColor(.white)
                                    }
                                }
                            } label: {
                                MyStuffCellView(symbol: route.symbol, title: route.title, isNavigationLabel: true)
                            }
                        }
                    }
                    VStack(spacing: 0) {
                        Button {
                            self.isShowingSettingsView.toggle()
                        } label: {
                            MyStuffCellView(symbol: "gear", title: "Settings")
                        }
                        Divider()
                        Button {
                            self.alertSignOut.toggle()
                        } label: {
                            MyStuffCellView(symbol: "key", title: "Sign Out")
                        }
                    }
                }
                .background(.gray.opacity(0.10))
                Spacer()
            }
        }
    }
}

fileprivate struct MyStuffCellView: View {
    
    let symbol: String
    let title: String
    
    var color: Color = Color(uiColor: .label)
    var isNavigationLabel: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                HStack(spacing: 10) {
                    Image(systemName: symbol)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .foregroundColor(color)
                    Text(title)
                        .font(.system(size: 20).bold())
                        .foregroundColor(Color(uiColor: .label))
                }
                Spacer()
                if isNavigationLabel {
                    Image(systemName: "chevron.right")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .frame(height: 90)
            .background(Color(uiColor: .systemBackground))
        }
    }
}

struct MyStuffView_Previews: PreviewProvider {
    static var previews: some View {
        MyStuffView()
            .environmentObject(UserViewModel())
            .environmentObject(ReportsViewModel())
    }
}
