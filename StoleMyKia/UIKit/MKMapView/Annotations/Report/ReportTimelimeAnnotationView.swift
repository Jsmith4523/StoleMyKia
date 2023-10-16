//
//  ReportTimelimeAnnotationView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/11/23.
//

import UIKit
import MapKit
import SwiftUI

class ReportTimelineAnnotationView: MKMarkerAnnotationView {
    
    private var reportAnnotation: ReportAnnotation
    private var report: Report
        
    init(annotation: ReportAnnotation) {
        self.reportAnnotation = annotation
        self.report = annotation.report
        super.init(annotation: annotation, reuseIdentifier: ReportAnnotation.reusableID)
        self.createAnnotationView()
        self.clusteringIdentifier = nil
    }
    
    override var annotation: MKAnnotation? {
        willSet {
            self.displayPriority = .required
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    private func createAnnotationView() {
        self.animatesWhenAdded = true
        self.canShowCallout = true
        self.glyphImage = UIImage(systemName: report.reportType.annotationImage)
        self.markerTintColor = report.reportType.annotationColor
    }
}
