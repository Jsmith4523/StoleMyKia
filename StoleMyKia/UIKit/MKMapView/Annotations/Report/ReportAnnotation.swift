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
    
    static var reusableID = "reportAnnotation"
    
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    var report: Report
    
    init(report: Report) {
        self.coordinate    = (report.location?.coordinates!)!
        self.report        = report
        self.subtitle      = report.location?.name ?? report.location?.address ?? ""
    }
}


class ReportAnnotationView: MKMarkerAnnotationView {
    
    var report: Report!
    
    weak var calloutDelegate: AnnotationCalloutDelegate?
    
    init(annotation: MKAnnotation?, reuseIdentifier: String?, report: Report) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.report = report
        
        clusteringIdentifier = ReportAnnotation.reusableID
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCalloutDelegate(_ delegate: AnnotationCalloutDelegate) {
        self.calloutDelegate = delegate
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        
        guard let report else { return }
        
        animatesWhenAdded  = true
        subtitleVisibility = .visible
        
        glyphImage      = UIImage(systemName: report.reportType.annotationImage)
        markerTintColor = report.reportType.annotationColor
        
        let calloutView = ReportAnnotationCallOut(report: report)
        calloutView.calloutDelegate = self.calloutDelegate
        
        canShowCallout = true
        detailCalloutAccessoryView = calloutView
    }
}


extension MKMapView {
    
    ///Will generate and return an array of ReportAnnotation
    func createAnnotations(_ reports: [Report]) {
        var reportIds = Set<UUID>()
        var annotations = [ReportAnnotation]()
        
        for annotation in self.annotations where annotation is ReportAnnotation {
            if let annotation = annotation as? ReportAnnotation {
                reportIds.insert(annotation.report.id)
                annotations.append(annotation)
            }
        }
            
        let newReportAnnotations = annotations.doesNotAlreadyContain(reportIds, with: reports)
        self.addAnnotations(newReportAnnotations)
    }
    
    func removeAnnotation(_ report: Report) {
        for annotation in self.annotations where annotation is ReportAnnotation {
            if let annotation = annotation as? ReportAnnotation, (annotation.report.id == report.id) {
                removeAnnotation(annotation)
            }
        }
    }
}

extension [ReportAnnotation] {
    
    func doesNotAlreadyContain(_ ids: Set<UUID>, with reports: [Report]) -> [ReportAnnotation] {
        let reports = reports.filter { report in
            !ids.contains(where: { $0 == report.id})
        }
            
        return reports.createAnnotations()
    }
}

extension [Report] {
    
    
    func createAnnotations() -> [ReportAnnotation] {
        var annotations = [ReportAnnotation]()
        
        for report in self {
            annotations.append(ReportAnnotation(report: report))
        }
        
        return annotations
    }
}

extension [MKAnnotation] {
    
    ///If the parameter array of reports does not contain the report(s) from the map annotations, remove them
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
