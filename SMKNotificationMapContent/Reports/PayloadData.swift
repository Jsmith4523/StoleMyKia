//
//  PayloadData.swift
//  SMKNotificationMapContent
//
//  Created by Jaylen Smith on 1/3/24.
//

import Foundation
import MapKit

struct PayloadData: Decodable {
    let lat: String
    let long: String
    let reportId: String
    let reportType: ReportType
    let discloseLocation: String
    let vehicleDetails: String
    let notificationType: String
    let imageURL: String?
}

extension PayloadData {
    
    var shouldDiscloseLocation: Bool {
        return Bool(discloseLocation)!
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(long)!)
    }
    
    var location: CLLocation {
        return CLLocation(latitude: Double(lat)!, longitude: Double(long)!)
    }
    
    var region: MKCoordinateRegion {
        return MKCoordinateRegion(center: coordinate, span: .init(latitudeDelta: 0.009, longitudeDelta: 0.009))
    }
}
