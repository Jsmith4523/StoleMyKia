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

extension ReportAnnotation {
    
    ///Will generate and return an array of ReportAnnotation 
    static func createAnnotaitons(_ reports: [Report]) -> [ReportAnnotation] {
        return reports.compactMap { report in
                .init(coordinate: report.coordinates, report: report)
        }
    }
}

extension [MKAnnotation] {
    
    ///If the parameter array of reports does not contain the report(s) from the map annotation, remove them
    func doesNotInclude(_ arr: [Report]) -> [ReportAnnotation] {
        var removeAnnotations = [ReportAnnotation]()
        
        for annotation in self where annotation is ReportAnnotation {
            if let annotation = annotation as? ReportAnnotation, !(arr.contains(where: {$0.id == annotation.report.id})) {
                removeAnnotations.append(annotation)
            }
        }
        
        return removeAnnotations
    }
}
