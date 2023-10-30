//
//  FeedView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/10/23.
//

import SwiftUI
import CoreLocation

struct FeedView: View {
    
    private enum FeedTabSelection: Identifiable, CaseIterable {
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
        
        var symbol: String {
            switch self {
            case .desired:
                return "line.3.horizontal"
            case .local:
                return "location"
            }
        }
    }
    
    @State private var tabViewSelection: FeedTabSelection = .desired
        
    @ObservedObject var userVM: UserViewModel
    @ObservedObject var reportsVM: ReportsViewModel
    
    var body: some View {
        NavigationStack {
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
            .environmentObject(userVM)
            .environmentObject(reportsVM)
            .navigationTitle(ApplicationTabViewSelection.feed.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text(ApplicationTabViewSelection.feed.title)
                        .font(.system(size: 20).weight(.heavy))
                }
                ToolbarItem(placement: .principal) {
                    Picker("", selection: $tabViewSelection) {
                        ForEach(FeedTabSelection.allCases) { selection in
                            Image(systemName: selection.symbol)
                                .tag(selection)
                        }
                    }
                    .frame(width: 140)
                    .pickerStyle(.segmented)
                }
            }
            .onChange(of: tabViewSelection) { _ in
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }
    }
}
