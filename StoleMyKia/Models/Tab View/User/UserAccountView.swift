//
//  UserAccountView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/27/23.
//

import SwiftUI
import MapKit

struct UserAccountView: View {
    
    private enum AccountViewSelection: CaseIterable {
        case userReports
        //case favorites
        
        var icon: String {
            switch self {
            case .userReports:
                return "line.3.horizontal"
//            case .favorites:
//                return "bookmark.fill"
            }
        }
    }
    
    @State private var viewSelection: AccountViewSelection = .userReports
    
    @State private var isShowingSettingsView = false
    
    @ObservedObject var userModel: UserViewModel
    
    @EnvironmentObject var notificationModel: NotificationViewModel
    @EnvironmentObject var reportsModel: ReportsViewModel
    
    
    var body: some View {
        CustomNavView(title: "My Account", statusBarColor: .darkContent, backgroundColor: .brand) {
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 35)
                userHeader
                VStack(spacing: 0) {
                    //tabViewSelection
                    TabView(selection: $viewSelection) {
                        UserReportsView(userModel: userModel)
                            .tag(AccountViewSelection.userReports)

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
                            .foregroundColor(.white)
                    }
                }
            }
            .refreshable {
                
            }
        }
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            userModel.userReportsDelegate = reportsModel
        }
        .sheet(isPresented: $isShowingSettingsView) {
            SettingsView()
                .environmentObject(userModel)
                .environmentObject(notificationModel)
                .environmentObject(reportsModel)
        }
    }
    
    var userHeader: some View {
        VStack {
            HStack(alignment: .top) {
                Image.userPlaceholder
                    .resizable()
                    .scaledToFill()
                    .frame(width: 75, height: 75)
                    .clipShape(Circle())
                VStack(alignment: .leading) {
                    Text("Hello There!")
                        .font(.system(size: 30).weight(.heavy))
                    VStack(alignment: .leading) {
                        if let displayName = userModel.getUserDisplayName() {
                            Text("User \(displayName)")
                        }
                        if let date = userModel.getUserCreationDate() {
                            Text("Member since \(date.date)")
                        }
                    }
                    .font(.system(size: 17))
                    .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding()
            Divider()
        }
    }
    
    var tabViewSelection: some View {
        VStack {
            HStack {
                ForEach(AccountViewSelection.allCases, id: \.icon) { selection in
                    Spacer()
                    Image(systemName: selection.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 21, height: 21)
                        .foregroundColor(self.viewSelection == selection ? .brand : .gray)
                        .padding()
                        .onTapGesture {
                            setTabViewSelection(selection)
                        }
                    Spacer()
                }
            }
            .padding(.horizontal)
            Divider()
        }
    }
    
    private func setTabViewSelection(_ selection: AccountViewSelection) {
        UIImpactFeedbackGenerator().impactOccurred(intensity: 4)
        withAnimation {
            self.viewSelection = selection
        }
    }
}


struct UserAccView_Previews: PreviewProvider {
    static var previews: some View {
        UserAccountView(userModel: UserViewModel())
            .environmentObject(NotificationViewModel())
            .environmentObject(ReportsViewModel())
    }
}
