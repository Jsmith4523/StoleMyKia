//
//  MapNavigationBar.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/8/23.
//

import SwiftUI

struct MapNavigationBar: View {
    
    @EnvironmentObject var notificationModel: NotificationViewModel
    @EnvironmentObject var reportsModel: ReportsViewModel
    @EnvironmentObject var userModel: UserViewModel
    
    @State private var filter: ReportType? = .none
    
    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(colors: [.clear, .black.opacity(0.35)], startPoint: .bottom, endPoint: .top)
                .frame(height: 200)
                .ignoresSafeArea()
            VStack(spacing: 13) {
                HStack {
                    Image(systemName: "sidebar.left")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .padding(10)
                        .background(Color.white)
                        .clipShape(Circle())
                        .fontWeight(.medium)
                        .shadow(radius: 0.5)
                    Spacer()
                    Text("Map")
                        .font(.system(size: 23).weight(.heavy))
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "bell")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .padding(10)
                        .background(Color.white)
                        .clipShape(Circle())
                        .fontWeight(.medium)
                        .shadow(radius: 0.5)
                }
                .frame(width: 375, height: 65)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        Spacer()
                        ForEach(ReportType.allCases) { type in
                            Label(type.rawValue, systemImage: type.annotationImage)
                                .padding(10)
                                .background(filter == type ? Color(uiColor: type.annotationColor) : Color(uiColor: .secondarySystemBackground))
                                .font(.system(size: 16).weight(.bold))
                                .foregroundColor(filter == type ? .white : Color.black)
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                .onTapGesture {
                                    withAnimation {
                                        filter = type
                                    }
                                }
                        }
                        Spacer()
                    }
                }
            }
        }
        Spacer()
    }
}

struct MapNavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        MapNavigationBar()
    }
}
