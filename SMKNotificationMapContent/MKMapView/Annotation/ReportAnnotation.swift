//
//  ReportAnnotation.swift
//  SMKNotificationMapContent
//
//  Created by Jaylen Smith on 12/31/23.
//

import Foundation
import MapKit

final class ReportAnnotation: NSObject, MKAnnotation {
    
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    var reportType: ReportType
    
    init(coordinate: CLLocationCoordinate2D, vehicleDetails: String, reportType: ReportType, locationDisclosed: Bool = false) {
        self.title      = "(\(reportType.rawValue)) \(vehicleDetails)"
        self.coordinate = coordinate
        self.reportType = reportType
        super.init()
        self.subtitle   = self.mileageDistanceFromUser()
    }
    
    ///Get the distance from the report type to the user's location in miles format
    private func mileageDistanceFromUser() -> String? {
        guard let userLocation = CLLocationManager().location else {
            return nil
        }
        
        let reportLocation = CLLocation(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)
        let distance = ((reportLocation.distance(from: userLocation)) * 0.000621371)
                
        return "\(String(format: "%.2f", distance)) mi. away from your current location"
    }
}
