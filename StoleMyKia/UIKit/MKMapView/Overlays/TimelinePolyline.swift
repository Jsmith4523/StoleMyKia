//
//  TimelinePolyline.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/20/23.
//

import UIKit
import MapKit

class TimelinePolyline: MKPolyline {
    
    var reports: [Report]!
}

extension TimelinePolyline {

    static var edgePadding: UIEdgeInsets {
        return .init(top: 100, left: 100, bottom: 100, right: 100)
    }
    
    var containsInitialReport: Bool {
        return (self.reports.filter({$0.role.isInitial}).count == 1)
    }
    
    var mustDiscloseLocation: Bool {
        return !(self.reports.filter({$0.discloseLocation}).count == 0)
    }
    var dashPattern: [NSNumber]? {
        if (mustDiscloseLocation || containsInitialReport) {
            return [8, 8, 8]
        }
        
        return nil
    }
    
    var strokeColor: UIColor {
        if containsInitialReport {
            if let initialReport = reports.filter({$0.role.isInitial}).first {
                return initialReport.reportType.annotationColor
            } else {
                return .systemBlue
            }
        } else {
            return .systemBlue
        }
    }
    
    var strokeWidth: CGFloat {
        switch mustDiscloseLocation {
        case true:
            return 1.75
        case false:
            return 2.5
        }
    }
}

extension [TimelinePolyline] {
    
    ///Retrieves the last timeline bounding map rect.
    func latestTimelineRect() -> MKMapRect? {
        guard !isEmpty else { return nil }
        let boundingMapRect = self.sorted(by: {$0.reports.sorted(by: >).first!.dt > $1.reports.sorted(by: >).first!.dt}).first!.boundingMapRect
        return boundingMapRect
    }
}
