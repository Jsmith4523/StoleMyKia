//
//  TimelineMapView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/11/23.
//

import SwiftUI

struct TimelineMapView: View {
    
    let report: Report
    
    var body: some View {
        VStack {
            TimelineMapViewRepresentabe(report: report)
        }
    }
}

struct TimelineMapView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TimelineMapView(report: .init(dt: Date.now.epoch, reportType: .found, vehicle: .init(vehicleYear: 2017, vehicleMake: .hyundai, vehicleColor: .black, vehicleModel: .kona), distinguishable: "", imageURL: "https://s3.us-east-2.amazonaws.com/dealer-inspire-vps-vehicle-images/c447-110005591/KM8K62AB0PU009265/7e3811453af8f6f40c7dcffda76f07e3.jpg", location: .init(name: "Grand Central Station", lat: 40.75110, lon: -73.97838)))
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
