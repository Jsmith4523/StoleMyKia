//
//  NewReportSearchLocation.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 4/11/23.
//

import SwiftUI
import MapKit

struct NewReportSearchLocation: View {
    
    @Binding var location: Location?
    
    @StateObject private var locationSearchModel = LocationSearchModel()
    @EnvironmentObject var mapModel: MapViewModel
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Address, Landmark, or Building", text: $locationSearchModel.request, onCommit: {
                    locationSearchModel.fetchLocations()
                })
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                ScrollView {
                    ForEach(locationSearchModel.locations) { location in
                        LocationSearchCellView(selectedLocation: $location, location: location)
                            .onTapGesture {
                                self.location = location
                            }
                        Divider()
                    }
                }
                Spacer()
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Close") {
                    dismiss()
                }
            }
        }
    }
    
    struct LocationSearchCellView: View {
        
        @Binding var selectedLocation: Location?
        
        let location: Location
        
        var body: some View {
            HStack {
                VStack(alignment: .leading) {
                    Text(location.name ?? "")
                        .font(.system(size: 16).bold())
                    Text(location.address ?? "")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }
                Spacer()
                if let selectedLocation,
                    selectedLocation.address == location.address {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.accentColor)
                }
            }
            .padding()
        }
    }
}

fileprivate final class LocationSearchModel: ObservableObject {
    
    @Published var request = ""
    @Published var locations = [Location]()
    
    func fetchLocations() {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = self.request
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, err in
            guard let response, err == nil else {
                return
            }
            self.locations = response.mapItems.compactMap {
                return .init(address: $0.placemark.title,
                             name: $0.name,
                             lat: $0.placemark.coordinate.latitude,
                             lon: $0.placemark.coordinate.longitude
                )
            }
        }
    }
}

///Object relating to MKLocalSearch for a report
struct Location: Codable, Identifiable {
    var id = UUID()
    let address: String?
    let name: String?
    let lat: Double?
    let lon: Double?
}

struct NewReportSearchLocation_Previews: PreviewProvider {
    static var previews: some View {
        NewReportSearchLocation(location: .constant(.init(address: "", name: "", lat: 0, lon: 0)))
            .environmentObject(MapViewModel())
    }
}
