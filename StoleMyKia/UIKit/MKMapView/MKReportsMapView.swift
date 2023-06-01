//
//  MKMapView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 5/31/23.
//

import UIKit
import MapKit

class MKReportsMapView: MKMapView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("I'm dead")
    }
}
