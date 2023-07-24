//
//  NewReportSearchLocation.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 4/11/23.
//

import SwiftUI
import MapKit

struct LocationSearchView: View {
    
    @Binding var location: Location?
    
    @StateObject private var locationSearchVM = LocationSearchViewModel()
    
    var body: some View {
        NavigationView {
            
        }
    }
}

final class LocationSearchViewModel: ObservableObject {
    
}

#Preview {
    LocationSearchView(location: .constant(.none))
}
