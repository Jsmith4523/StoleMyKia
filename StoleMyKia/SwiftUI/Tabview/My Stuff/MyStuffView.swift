//
//  MyStuffView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 9/19/23.
//

import SwiftUI

struct MyStuffView: View {
    
    enum MyStuffRoute: CaseIterable, Identifiable {
        case reports, bookmarks, settings
        
        var id: Self {
            return self
        }
        
        var title: String {
            switch self {
            case .bookmarks:
                return "Bookmarks"
            case .reports:
                return "Reports"
            case .settings:
                return "Settings"
            }
        }
        
        var symbol: String {
            switch self {
            case .bookmarks:
                return "bookmark"
            case.reports:
                return ApplicationTabViewSelection.feed.symbol
            case .settings:
                return "gear"
            }
        }
    }
    
    @State private var alertSignOut = false
    
    @State private var route: MyStuffRoute?
            
    @ObservedObject var userVM: UserViewModel
    @ObservedObject var reportsVM: ReportsViewModel
        
    var body: some View {
        NavigationController(title: ApplicationTabViewSelection.myStuff.title, statusBarColor: .lightContent, backgroundColor: .brand) {
            ScrollView {
                VStack(spacing: 0) {
                    header
                    buttons
                }
            }
            .hideNavigationTitle()
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
        .sheet(item: $route) { route in
            switch route {
            case .reports:
                UserReportsView()
                    .environmentObject(userVM)
                    .environmentObject(reportsVM)
            case .bookmarks:
                EmptyView()
            case .settings:
                SettingsView()
                    .presentationDragIndicator(.visible)
                    .environmentObject(userVM)
            }
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
    }
    
    var buttons: some View {
        ZStack {
            VStack {
                VStack(spacing: 0) {
                    ForEach(MyStuffRoute.allCases) { route in
                        Divider()
                        Button {
                            self.route = route
                        } label: {
                            MyStuffCellView(symbol: route.symbol, title: route.title)
                        }
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
            .preferredColorScheme(.dark)
    }
}
