//
//  ReportTimelineCircleOverlay.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/13/23.
//

import Foundation
import MapKit

class ReportTimelineCircleOverlay: MKCircle {
        
    let color: UIColor
    
    init(report: Report) {
        self.color = report.reportType.annotationColor.withAlphaComponent(0.35)
        super.init()
    }
}
