//
//  NewReportSearchLocation.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 4/11/23.
//

import SwiftUI
import MapKit

struct NearbyLocationSearchView: View {
    
    @State private var presentAlert = false
    @State private var alertReason = ""
    
    @State private var requestQuery = ""
    @Binding var location: Location?
    
    @StateObject private var locationSearchVM = LocationSearchViewModel()
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            GeometryReader { _ in
                VStack {
                    VStack {
                        TextField(text: $requestQuery) {
                            Text("Enter Address or name")
                        }
                        .padding(6)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .padding(.horizontal)
                        .onSubmit {
                            searchForLocations()
                        }
                    }
                    switch locationSearchVM.loadStatus {
                    case .loading:
                        ProgressView()
                    case .loaded:
                        list
                    case .idle:
                        NearbySearchIdleView()
                    case .noResults:
                        NearbySearchNoResultsView()
                    case .error:
                        NearbyLocationSearchErrorView()
                    case .locationServicesDenied:
                        NearbySearchLocationServicesView()
                    case .locationError:
                        NearbySearchUserLocationErrorView()
                    }
                }
            }
            .navigationTitle("Nearby Locations")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        useUsersCurrentLocation()
                    } label: {
                        Image(systemName: "location")
                    }
                }
            }
            .alert(alertReason, isPresented: $presentAlert) {
                Button("OK") {}
            }
        }
    }
    
    private var list: some View {
        ScrollView {
            VStack {
                ForEach(locationSearchVM.locations) { location in
                    LocationSearchCellView(location: location, isSelected: self.location?.address == location.address)
                        .onTapGesture {
                            setLocationToReport(location)
                        }
                    Divider()
                }
            }
        }
    }
    
    private func searchForLocations() {
        Task {
            await locationSearchVM.fetchNearbyLocations(query: requestQuery)
        }
    }
    
    private func useUsersCurrentLocation() {
        guard CLLocationManager.shared.authorizationStatus.isAuthorized else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            self.alertReason = "Your location services settings are disabled. Please enable them in the 'Settings' app."
            self.presentAlert.toggle()
            return
        }
        
        guard let userLocation = CLLocationManager.shared.location else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            self.alertReason = "Unable to locate your current location."
            self.presentAlert.toggle()
            return
        }
        
        //Setting the location to nil since if the user changes their location whilst completing the report (let's say they're driving), then the location will be updating.
        setLocationToReport(nil)
    }
    
    private func setLocationToReport(_ location: Location?) {
        self.location = location
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            dismiss()
        }
    }
}

final fileprivate class LocationSearchViewModel: ObservableObject {
    
    enum LocationSearchLoadStatus {
        case idle, loading, loaded, noResults, error, locationServicesDenied, locationError
    }
    
    @Published private(set) var loadStatus: LocationSearchLoadStatus = .idle
    @Published private(set) var locations = [Location]()
    
    private let locationManager = CLLocationManager()
    
    @MainActor
    ///Fetches for locations within the radius of the user's current location.
    func fetchNearbyLocations(query: String) async {
        self.loadStatus = .loading
        do {
            guard locationManager.authorizationStatus.isAuthorized else {
                self.loadStatus = .locationServicesDenied
                return
            }
            
            guard let usersCurrentLocation = locationManager.location else {
                self.loadStatus = .locationError
                return
            }
            
            guard !(query.isEmpty) else {
                return
            }
            
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            
            let search = MKLocalSearch(request: request)
            let response = try await search.start()
            //Filtering locations within a mile from the users current location
//            let locations = response.mapItems
//                .filter({usersCurrentLocation.calculateDistanceInMiles(to: $0.location) <= 1})
//                .map ({Location(address: $0.placemark.title, name: $0.name, coordinate: $0.placemark.coordinate)})
//            
//            
//            guard !(locations.isEmpty) else {
//                self.locations = []
//                self.loadStatus = .noResults
//                return
//            }
//            self.locations = locations
//            self.loadStatus = .loaded
        }
        catch {
            self.loadStatus = .error
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
}

//#Preview {
//    NearbyLocationSearchView(location: .constant(.none))
//}
