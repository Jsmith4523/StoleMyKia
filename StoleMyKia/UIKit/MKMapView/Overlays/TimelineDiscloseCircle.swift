//
//  TimelineDiscloseCircle.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/22/23.
//

import UIKit
import MapKit

class TimelineDiscloseCircle: MKCircle {
    
    var report: Report!

    var distanceFromTapGesture: Int!
}

extension TimelineDiscloseCircle {
    
    var edgePadding: UIEdgeInsets {
        return .init(top: 100, left: 75, bottom: 125, right: 75)
    }
    
    var fillColor: UIColor {
        switch report.role.isInitial {
        case true:
            return report.reportType.annotationColor.withAlphaComponent(0.25)
        case false:
            return MKCircle.discloseLocationFillColor
        }
    }
}
