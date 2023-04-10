//
//  MapSettingsView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/15/23.
//

import SwiftUI
import MapKit


struct MapSettingsView: View {
    
    private enum mapType: String, CaseIterable {
        case standard = "Standard"
        case satelite = "Satelite"
        
        var value: Int {
            switch self {
            case .standard:
                return 0
            case .satelite:
                return 2
            }
        }
    }
    
    @EnvironmentObject var reportsModel: ReportsViewModel
    
    var body: some View {
        List {
//            Section {
//                Picker(selection: $reportsModel.mapType) {
//                    ForEach (mapType.allCases, id: \.rawValue) {
//                        Text($0.rawValue)
//                            .tag($0.value)
//                    }
//                } label: {}
//                .pickerStyle(.inline)
//            } header: {
//                Text("Appearance")
//            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MapSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        MapSettingsView()
            .environmentObject(ReportsViewModel())
    }
}
