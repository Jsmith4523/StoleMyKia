//
//  NewReportSearchLocation.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 4/11/23.
//

import SwiftUI
import MapKit

struct LocationSearchView: View {
    
    @State private var alertErrorUsingUsersLocation = false
    
    @Binding var location: Location?
    
    @StateObject private var locationSearchModel = LocationSearchModel()
    
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
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .bold()
                    }
                }
            }
            .alert("Unable to use your location", isPresented: $alertErrorUsingUsersLocation) {
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
            if locationSearchModel.locationIsAuthorized {
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
        guard let usersLocation = locationSearchModel.usersLocation else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            self.alertErrorUsingUsersLocation.toggle()
            return
        }
        
        let coords = usersLocation.coordinate
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
    
    private let locationManager = CLLocationManager()
    
    var locationIsAuthorized: Bool {
        locationManager.authorizationStatus.isAuthorized
    }
    
    var usersLocation: CLLocation? {
        locationManager.location
    }
        
    func fetchLocations() {
        let request = MKLocalSearch.Request()
        
        //The thefts are only target within the United States (for now)
        let usaRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.0902, longitude: -95.7129),
                                           span: MKCoordinateSpan(latitudeDelta: 5000000, longitudeDelta: 5000000))
        
        guard !(self.request.isEmpty) else {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            return
        }
        
        request.naturalLanguageQuery = self.request
        request.region = usaRegion
        
        let search = MKLocalSearch(request: request)
        search.start { response, err in
            guard let response, err == nil else {
                self.didNotFindLocations()
                return
            }
            
            let locations = response.mapItems.withinSpan(region: usaRegion)
            
            guard !(locations.isEmpty) else {
                self.didNotFindLocations()
                return
            }
            
            self.locations = locations.compactMap {
                return .init(address: $0.placemark.title,
                             name: $0.name,
                             lat: $0.placemark.coordinate.latitude,
                             lon: $0.placemark.coordinate.longitude
                )
            }
        }
    }
    
    private func didNotFindLocations() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        self.alertSearchingForLocation.toggle()
    }
}

extension [MKMapItem] {
    
    ///Will return locations that are in a specific region span.
    ///For example, only show locations that are in the United States region.
    func withinSpan(region: MKCoordinateRegion) -> [MKMapItem] {
        
        let location: CLLocation = CLLocation(latitude: region.center.latitude,
                                              longitude: region.center.longitude)
        
        return self.filter { mapItem in
            mapItem.location.distance(from: location) <= region.span.latitudeDelta
        }
    }
}


extension MKMapItem {
    
    var location: CLLocation {
        CLLocation(latitude: self.placemark.coordinate.latitude,
                   longitude: self.placemark.coordinate.longitude)
    }
}
