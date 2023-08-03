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
        self.canShowCallout = false
        self.animatesWhenAdded = true
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        displayPriority = .defaultHigh
    }
    
    private func setupView() {
        self.markerTintColor = report.reportType.annotationColor
        self.glyphImage = UIImage(systemName: report.reportType.annotationImage)
        self.subtitleVisibility = .visible
    }
}
