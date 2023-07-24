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
    static var twitterSupportURL: URL {
        URL(string: "https://twitter.com/StudentlyCo")!
    }
    
    static func openApplicationSettings() {
        guard let applicationUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        UIApplication.shared.open(applicationUrl)
    }
    
    static func getDirectionsToLocation(coords: CLLocationCoordinate2D) {
        let lat = coords.latitude
        let lon = coords.longitude
        
        if let url = URL(string: "maps://?q=\("Report Location"),saddr=&daddr=\(lat),\(lon)") {
            UIApplication.shared.open(url)
        }
    }
}

extension URLSession {
    func getData(_ url: URL, completion: @escaping ((Data?)->Void)) {
        self.dataTask(with: url) { data, response, err in
            guard let data = data, err == nil else {
                completion(nil)
                return
            }
            completion(data)
        }
        .resume()
    }
}
