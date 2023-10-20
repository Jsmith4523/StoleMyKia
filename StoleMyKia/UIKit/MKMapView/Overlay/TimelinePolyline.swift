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
    
    var containsInitialReport: Bool {
        return (self.reports.filter({$0.role.isInitial}).count == 1)
    }
    
    var mustDiscloseLocation: Bool {
        return !(self.reports.filter({$0.discloseLocation}).count == 0)
    }
    var dashPattern: [NSNumber] {
        if (mustDiscloseLocation || containsInitialReport) {
            return [8, 8, 8]
        } else {
            return [0]
        }
    }
    
    var strokeColor: UIColor {
        if containsInitialReport && mustDiscloseLocation {
            return .gray.withAlphaComponent(0.75)
        }
        
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
}
