//
//  ReportTypeFilterView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 8/13/23.
//

import SwiftUI
import CoreLocation

enum NearbyDistance: String, CaseIterable, Identifiable {
    case oneMile         = "1 Mile"
    case fiveMiles       = "5 Miles"
    case tenMiles        = "10 Miles"
    case twentyFiveMiles = "25 Miles"
    case fiftyMiles      = "50 Miles"
    
    private static let oneMeter = 1609.35
    
    var id: String {
        self.rawValue
    }
    
    var distance: Double {
        switch self {
        case .oneMile:
            return Self.oneMeter
        case .fiveMiles:
           return Self.oneMeter * 5
        case .tenMiles:
           return Self.oneMeter * 10
        case .twentyFiveMiles:
           return Self.oneMeter * 25
        case .fiftyMiles:
            return Self.oneMeter * 50
        }
    }
}

struct ReportFilterView: View {
    
    @State private var disableNearbyFilter = false
    
    @Binding var filterByUserLocation: Bool
    @Binding var nearbyDistance: NearbyDistance
    @Binding var reportType: ReportType?
    @Binding var reportRole: ReportRole.Role?
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Group {
                        Toggle("Show Nearby", isOn: $filterByUserLocation)
                            .tint(.green)
                        if filterByUserLocation {
                            Picker("", selection: $nearbyDistance) {
                                ForEach(NearbyDistance.allCases) {
                                    Text($0.rawValue)
                                        .tag($0)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                    .disabled(disableNearbyFilter)
                } header: {
                    Text("Nearby")
                } footer: {
                    Text("When enabled, you'll only see reports that are located nearby.")
                }
                Section("Reports") {
                    Picker("Report Type", selection: $reportType) {
                        ForEach(ReportType.allCases) {
                            Text($0.rawValue)
                                .tag($0)
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                let locationStatus = CLLocationManager.shared.authorizationStatus
                guard (locationStatus == .authorizedAlways  || locationStatus == .authorizedWhenInUse) else {
                    self.disableNearbyFilter = true
                    self.filterByUserLocation = false
                    return
                }
                self.disableNearbyFilter = false
            }
            .onAppear {
                let locationStatus = CLLocationManager.shared.authorizationStatus
                guard (locationStatus == .authorizedAlways  || locationStatus == .authorizedWhenInUse) else {
                    self.disableNearbyFilter = true
                    self.filterByUserLocation = false
                    return
                }
                self.disableNearbyFilter = false
            }
        }
        .tint(Color(uiColor: .label))
    }
}

struct ReportTypeFilterView_Previews: PreviewProvider {
    static var previews: some View {
        ReportFilterView(filterByUserLocation: .constant(true), nearbyDistance: .constant(.fiveMiles),reportType: .constant(.attempt), reportRole: .constant(.original))
    }
}
