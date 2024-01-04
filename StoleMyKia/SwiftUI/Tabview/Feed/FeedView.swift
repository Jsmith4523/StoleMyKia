//
//  FeedView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/10/23.
//

import SwiftUI
import CoreLocation

struct FeedView: View {
    
    private enum FeedTabSelection: CustomTabViewPickerSource {
        case desired, local
        
        var id: Self { return self }
        
        var title: String {
            switch self {
            case .desired:
                return "General"
            case .local:
                return "Nearby"
            }
        }
        
        var composeButtonColor: Color {
            switch self {
            case .desired:
                return .brand
            case .local:
                return .blue
            }
        }
    }
    
    @State private var tabViewSelection: FeedTabSelection = .desired
        
    @ObservedObject var userVM: UserViewModel
    @ObservedObject var reportsVM: ReportsViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                CustomTabViewPicker(selection: $tabViewSelection, sources: FeedTabSelection.allCases)
                ZStack {
                    TabView(selection: $tabViewSelection) {
                        FeedDesiredView()
                            .tag(FeedTabSelection.desired)
                            .environmentObject(userVM)
                            .environmentObject(reportsVM)
                        FeedLocalView()
                            .tag(FeedTabSelection.local)
                            .environmentObject(userVM)
                            .environmentObject(reportsVM)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    FeedNewReportButtonView()
                        .environmentObject(userVM)
                        .environmentObject(reportsVM)
                }
            }
            .environmentObject(userVM)
            .environmentObject(reportsVM)
            .navigationTitle(ApplicationTabViewSelection.feed.title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    FeedView(userVM: UserViewModel(), reportsVM: ReportsViewModel())
}
