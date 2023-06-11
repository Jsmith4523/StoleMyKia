//
//  ReportTimelimeAnnotationView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/11/23.
//

import UIKit
import MapKit
import SwiftUI

class ReportTimelineAnnotationView: MKAnnotationView {
    
    private var report: Report
    
    init(annotation: ReportAnnotation) {
        self.report = annotation.report
        super.init(annotation: annotation, reuseIdentifier: ReportAnnotation.reusableID)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
    }
    
    private func setupView() {
        let circleView = UIView()
        circleView.frame = .init(x: 0, y: 0, width: 33, height: 33)
        circleView.backgroundColor = report.reportType.annotationColor
        circleView.clipsToBounds = true
        circleView.layer.cornerRadius = circleView.frame.height / 2
        
        let icon = UIImage(systemName: report.reportType.annotationImage)
        let iconView = UIImageView(image: icon)
        
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit
        
        addSubview(circleView)
        addSubview(iconView)
        
        circleView.translatesAutoresizingMaskIntoConstraints = false
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            circleView.centerXAnchor.constraint(equalTo: centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: centerYAnchor),
            circleView.widthAnchor.constraint(equalToConstant: 33),
            circleView.heightAnchor.constraint(equalToConstant: 33),
            iconView.widthAnchor.constraint(equalToConstant: 23),
            iconView.heightAnchor.constraint(equalToConstant: 23),
            iconView.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: circleView.centerYAnchor)
        ])
        
//        backgroundColor = .orange
//        frame.size = .init(width: 100, height: 100)
    }
}

struct PreviewView: UIViewRepresentable {
    
    let view: UIView
    
    func makeUIView(context: Context) -> UIView {
        view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
    
    typealias UIViewType = UIView

}

struct ReportTimeline_Previews: PreviewProvider {
    static var previews: some View {
        PreviewView(view: ReportTimelineAnnotationView(annotation: ReportAnnotation(report: [Report].testReports().randomElement()!)))
    }
}

