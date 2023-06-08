//
//  MapTabBar.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/8/23.
//

import SwiftUI

struct MapSheetView: View {
    
    enum SheetTabSelection: CaseIterable, Identifiable {
        case reports
        case userReports
        case updates
        case bookmarked
        
        var id: String {
            self.title
        }
        
        var title: String {
            switch self {
            case .reports:
                return "Reports"
            case .userReports:
                return "My Reports"
            case .updates:
                return "Updates"
            case .bookmarked:
                return "Bookmarks"
            }
        }
    }
    
    @EnvironmentObject var reportsModel: ReportsViewModel
    @EnvironmentObject var userModel: UserViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            VStack(spacing: 10) {
                HStack {
                    Button {
                        withAnimation {
                            reportsModel.mapSheetMode = reportsModel.mapSheetMode == .full ? .interactive : .full
                        }
                    } label: {
                        Label("Report Theft", systemImage: "exclamationmark.triangle.fill")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.brand)
                            .cornerRadius(15)
                    }
                    Image(systemName: "camera.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .padding(13)
                        .background(.gray.opacity(0.5))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                Divider()
            }
            .padding([.top, .horizontal])
            ScrollView {
                
            }
        }
    }
}

struct MapTabBar_Previews: PreviewProvider {
    static var previews: some View {
        MapSheetView()
            .environmentObject(ReportsViewModel())
            .environmentObject(UserViewModel())
    }
}
