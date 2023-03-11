//
//  ContentView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/11/23.
//

import SwiftUI

struct Tab: View {
    
    @EnvironmentObject var reportsModel: ReportsViewModel
    
    var body: some View {
        TabView {
            MapView()
                .tabItem {
                    Label("Reports", systemImage: "mappin.and.ellipse")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Tab()
            .environmentObject(ReportsViewModel())
    }
}
