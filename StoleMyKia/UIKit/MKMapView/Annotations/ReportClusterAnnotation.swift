//
//  ReportClusterAnnotation.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/18/23.
//

import Foundation
import UIKit
import MapKit

class ReportsClusterAnnotationView: MKAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        setupView()
    }
    
    private func setupView() {
        if let clusterAnnotation = annotation as? MKClusterAnnotation {
            let circle = UIView()
            circle.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            circle.backgroundColor = .tintColor
            circle.layer.cornerRadius = circle.frame.height / 2
            circle.clipsToBounds = true
            
            let labelView = UILabel()
            labelView.text = clusterAnnotation.countString
            labelView.font = .systemFont(ofSize: 19.5, weight: .heavy)
            labelView.textColor = .white
            
            canShowCallout = true
            
            addSubview(circle)
            addSubview(labelView)
            
            circle.translatesAutoresizingMaskIntoConstraints = false
            labelView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                circle.centerYAnchor.constraint(equalTo: centerYAnchor),
                circle.centerXAnchor.constraint(equalTo: centerXAnchor),
                circle.widthAnchor.constraint(equalToConstant: CGFloat(40)),
                circle.heightAnchor.constraint(equalToConstant: CGFloat(40)),
                labelView.centerYAnchor.constraint(equalTo: circle.centerYAnchor),
                labelView.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
            ])
        }
    }
    
    func determinePreview(_ mapView: MKMapView) {
        if let annotation = annotation as? MKClusterAnnotation {
            
            let count = annotation.memberAnnotations.count
            //TODO: Setup VisibleMapRect
        }
    }
}


extension MKClusterAnnotation {
    
    
    var countString: String {
        let count = self.memberAnnotations.count
        
        if count > 10 {
            return "10+"
        } else {
            return "\(count)"
        }
    }
}
