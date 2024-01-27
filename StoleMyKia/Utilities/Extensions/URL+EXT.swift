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
    
    ///Twitter support url
    static var twitterSupportURL: URL {
        URL(string: "https://twitter.com/StudentlyCo")!
    }
    
    ///privacy policy url
    static let privacyPolicy = URL(string: "https://app.termly.io/document/privacy-policy/2ae30769-b86f-44e1-98c7-8187268c5989")!
    
    ///terms of use url
    static let termsAndService = URL(string: "https://app.termly.io/document/terms-of-service/34f06d4a-2797-4256-80a1-8b3159555581")!
    
    ///Disclaimer url
    static let disclaimerUrl = URL(string: "https://app.termly.io/document/disclaimer/9e564eeb-2c53-4a06-9527-ae82d7a6dd4c")!
    
    static func openApplicationSettings() {
        guard let applicationUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        UIApplication.shared.open(applicationUrl)
    }
    
    static func getDirectionsToLocation(title: String, coords: CLLocationCoordinate2D) {
        let lat = coords.latitude
        let lon = coords.longitude
        
        let title = title.replacingOccurrences(of: " ", with: "+")
                       
        if let url = URL(string: "maps://?q=\(title)&ll=\(lat),\(lon)") {
            UIApplication.shared.open(url)
        }
    }
}

extension URLSession {
    public func getData(_ url: URL, completion: @escaping ((Data?)->Void)) {
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
