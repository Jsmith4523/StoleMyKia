//
//  NewReportSearchLocation.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 4/11/23.
//

import SwiftUI
import MapKit

struct NewReportSearchLocation: View {
    
    @State private var alertErrorUsingUsersLocation = false
    
    @Binding var location: Location?
    
    @StateObject private var locationSearchModel = LocationSearchModel()
    @EnvironmentObject var mapModel: MapViewModel
    
    @Environment (\.dismiss) var dismiss
    
    @FocusState private var searchFieldFocus: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Address, Landmark, etc.", text: $locationSearchModel.request, onCommit: {
                    locationSearchModel.fetchLocations()
                })
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.alphabet)
                    .autocorrectionDisabled()
                    .padding(.horizontal)
                    .focused($searchFieldFocus)
                VStack {
                    useMyLocationButton
                    switch locationSearchModel.locations.isEmpty {
                    case true:
                        searchInstructionView
                    case false:
                        locationListView
                    }
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .alert("Unable to user your location", isPresented: $alertErrorUsingUsersLocation) {
                Button("OK") {}
            } message: {
                Text("An error occured when attempting to use your location.")
            }
            .alert("Nothing found!", isPresented: $locationSearchModel.alertSearchingForLocation) {
                Button("OK"){}
            } message: {
                Text("No locations where found by that name...")
            }
        }
    }
    
    var useMyLocationButton: some View {
        ZStack {
            if mapModel.locationAuth.isAuthorized() {
                Button {
                    useUsersLocation()
                } label: {
                    HStack {
                        Image(systemName: "location.fill")
                        Text("Use my Current Location")
                        Spacer()
                    }
                    .padding()
                }
            } else {
                Spacer()
                    .frame(height: 30)
            }
        }
    }
    
    var locationListView: some View {
        VStack {
            ScrollView {
                ForEach(locationSearchModel.locations) { location in
                    LocationSearchCellView(selectedLocation: $location, location: location)
                        .onTapGesture {
                            setLocation(location)
                        }
                    Divider()
                }
            }
        }
    }
    
    var searchInstructionView: some View {
        VStack(spacing: 25) {
            Spacer()
                .frame(height: 100)
            Image(systemName: "magnifyingglass")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
            Text("Search")
                .font(.system(size: 35).bold())
            Text("Start by entering a address, landmark, or other identifiable information.")
                .font(.system(size: 15))
                .foregroundColor(.gray)
            Spacer()
        }
        .padding()
        .multilineTextAlignment(.center)
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
    
    private func useUsersLocation() {
        guard let location = mapModel.userLocation else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            self.alertErrorUsingUsersLocation.toggle()
            return
        }
        
        let coords = location.coordinate
        
        let userLocation = Location(address: "", name: "", lat: coords.latitude, lon: coords.longitude)
        
        setLocation(userLocation)
    }
    
    private func setLocation(_ location: Location) {
        self.location = location
        UIImpactFeedbackGenerator().impactOccurred(intensity: 5)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            dismiss()
        }
    }
}

fileprivate final class LocationSearchModel: ObservableObject {
    
    @Published var alertSearchingForLocation = false
    
    @Published var request = ""
    @Published var locations = [Location]()
    
    func fetchLocations() {
        let searchRequest = MKLocalSearch.Request()
        
        guard !(request.isEmpty) else {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            return
        }
        
        searchRequest.naturalLanguageQuery = self.request
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, err in
            guard let response, err == nil else {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                self.alertSearchingForLocation.toggle()
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
