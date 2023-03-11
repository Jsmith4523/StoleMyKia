//
//  ReportsViewModel.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/11/23.
//

import Foundation
import SwiftUI
import UIKit
import MapKit

final class ReportsViewModel: NSObject, ObservableObject {
    
    
    @Published var reports = [Report]()
    
}


extension ReportsViewModel: MKMapViewDelegate {
    
    
    
}
