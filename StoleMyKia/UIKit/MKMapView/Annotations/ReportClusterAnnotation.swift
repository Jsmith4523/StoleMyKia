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
    }
}
