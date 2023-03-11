//
//  MapView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/11/23.
//

import SwiftUI

struct MapView: View {
    
    @EnvironmentObject var reportModel: ReportsViewModel
    
    var body: some View {
        NavigationView {
            MapViewRep()
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .environmentObject(ReportsViewModel())
    }
}
