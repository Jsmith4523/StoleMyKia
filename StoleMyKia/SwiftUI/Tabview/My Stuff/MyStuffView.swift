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
                return "My Reports"
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
    
    @State private var isShowingSettingsView = false
    @State private var alertSignOut = false
                
    @ObservedObject var userVM: UserViewModel
    @ObservedObject var reportsVM: ReportsViewModel
    @EnvironmentObject var authVM: FirebaseAuthViewModel
        
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Color.brand
                    .frame(height: 100)
                //Offsetting the scrollview due to a very-thin but visible white gap during modal presentations
                ScrollView {
                    VStack(spacing: 0) {
                        header
                        buttons
                    }
                }
                .offset(y: -0.5)
            }
            .navigationBarHidden(true)
            .navigationTitle(ApplicationTabViewSelection.myStuff.title)
            .edgesIgnoringSafeArea(.top)
            .background {
                HostingView(statusBarStyle: .darkContent) {
                    EmptyView()
                        .disabled(true)
                }
            }
        }
        .ignoresSafeArea()
        .accentColor(.white)
        .tint(Color(uiColor: .label))
        .alert("Sign Out", isPresented: $alertSignOut) {
            Button("Cancel") {}
            Button("Yes") {
                authVM.signOutUser()
            }
        } message: {
            Text("You'll be signed out of \(userVM.getAuthUserPhoneNumber() ?? "the application"). Are you sure?")
        }
        .sheet(isPresented: $isShowingSettingsView) {
            SettingsView()
                .presentationDragIndicator(.visible)
                .environmentObject(authVM)
                .environmentObject(userVM)
        }
    }
    
    var header: some View {
        ZStack {
            GeometryReader { proxy in
                Color.brand
                    .offset(y: -proxy.frame(in: .global).minY)
                    .frame(height: (proxy.frame(in: .global).minY + 125) <= 0 ? 0 : proxy.frame(in: .global).minY + 125)
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
        .frame(maxWidth: .infinity)
        .frame(height: 125)
    }
    
    var buttons: some View {
        ZStack {
            VStack {
                VStack(spacing: 0) {
                    ForEach(MyStuffRoute.allCases) { route in
                        Divider()
                        NavigationLink {
                            switch route {
                            case .reports:
                                UserReportsView()
                                    .environmentObject(userVM)
                                    .environmentObject(reportsVM)
                            case .bookmarks:
                                UserBookmarksView()
                                    .environmentObject(userVM)
                                    .environmentObject(reportsVM)
                            }
                        } label: {
                            MyStuffCellView(symbol: route.symbol, title: route.title, isNavigationLabel: true)
                        }
                    }
                    Divider()
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
        MyStuffView(userVM: UserViewModel(), reportsVM: ReportsViewModel())
    }
}
