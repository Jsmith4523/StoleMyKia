//
//  ReportClusterAnnotation.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/18/23.
//

import Foundation
import UIKit
import MapKit

final class ReportClusterAnnotation: MKClusterAnnotation {
    
    var reportAnnotations: [ReportAnnotation]
        
    override init(memberAnnotations: [MKAnnotation]) {
        let reportAnnotations = memberAnnotations.compactMap({$0 as? ReportAnnotation})
        self.reportAnnotations = reportAnnotations
        
        super.init(memberAnnotations: reportAnnotations)
    }
}


extension ReportClusterAnnotation {
    
    
    var countString: String {
        let count = self.memberAnnotations.count
        
        if count > 99 {
            return "99+"
        } else {
            return "\(count)"
        }
    }
}
