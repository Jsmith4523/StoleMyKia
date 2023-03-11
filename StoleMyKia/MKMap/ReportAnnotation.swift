//
//  ReportAnnotation.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/11/23.
//

import Foundation
import UIKit
import SwiftUI
import MapKit

class ReportAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var report: Report
    
    init(coordinate: CLLocationCoordinate2D, report: Report) {
        self.coordinate = coordinate
        self.report     = report
    }
}
