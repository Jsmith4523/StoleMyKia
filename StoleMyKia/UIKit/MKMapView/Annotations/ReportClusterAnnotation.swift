//
//  ReportClusterAnnotation.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/18/23.
//

import Foundation
import UIKit
import MapKit

class ReportClusterAnnotation: MKClusterAnnotation {
    
    var reports: [Report]!
    
    override init(memberAnnotations: [MKAnnotation]) {
        super.init(memberAnnotations: memberAnnotations)
        
        if let reports = memberAnnotations as? [Report] {
            self.reports = reports
        }
    }
}
