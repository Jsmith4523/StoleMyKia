//
//  MKMapItem.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 7/23/23.
//

import Foundation
import MapKit

extension [MKMapItem] {
    
    
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
