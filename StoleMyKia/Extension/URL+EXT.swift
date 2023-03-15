//
//  URL+EXT.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/13/23.
//

import Foundation
import UIKit
import MapKit

extension URL {
    
    static func applicationSettings() -> String {
        UIApplication.openSettingsURLString
    }
    
    static func getDirectionsToLocation(coords: CLLocationCoordinate2D) {
        let lat = coords.latitude
        let lon = coords.longitude
        
        if let url = URL(string: "http://maps.apple.com/?ll=\(lat),\(lon)") {
            UIApplication.shared.open(url)
        }
    }
}
