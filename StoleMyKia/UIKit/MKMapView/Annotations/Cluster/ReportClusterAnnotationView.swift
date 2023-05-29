//
//  ReportClusterAnnotationView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 5/28/23.
//

import Foundation
import MapKit
import SwiftUI
import UIKit

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
        if let clusterAnnotation = annotation as? ReportClusterAnnotation {
            let circle = UIView()
            circle.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            circle.backgroundColor = UIColor(Color.brand)
            circle.layer.cornerRadius = circle.frame.height / 2
            circle.clipsToBounds = true
            
            let labelView = UILabel()
            labelView.text = clusterAnnotation.countString
            labelView.font = .systemFont(ofSize: 17, weight: .heavy)
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
}
