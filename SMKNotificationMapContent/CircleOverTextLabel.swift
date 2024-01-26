//
//  CircleOverTextLabel.swift
//  SMKNotificationMapContent
//
//  Created by Jaylen Smith on 1/7/24.
//

import UIKit
import CoreLocation

class CircleOverTextLabel: UILabel {

    private var optionalText: String?
    private var data: PayloadData
    
    init(data: PayloadData, optionalText: String? = nil) {
        self.data = data
        self.optionalText = optionalText
        super.init(frame: .zero)
        self.configureTextView()
    }
    
    private func configureTextView() {
        textAlignment = .center
        numberOfLines = 3
        font = .systemFont(ofSize: 14.5, weight: .bold)
        text = "\(optionalText ?? mileageDistanceFromUser(data.location) ?? "")"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///Get the distance from the report type to the user's location in miles format
    private func mileageDistanceFromUser(_ location: CLLocation) -> String? {
        guard let userLocation = CLLocationManager().location else {
            return nil
        }
        
        let distance = ((location.distance(from: userLocation)) * 0.000621371)
                
        return "\(String(format: "%.2f", distance)) mi. away"
    }
    
    override func drawText(in rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(2.5)
        context?.setLineJoin(.round)
        context?.setTextDrawingMode(.stroke)
        self.textColor = .darkText.withAlphaComponent(0.85)
        super.drawText(in: rect)
        context?.setTextDrawingMode(.fill)
        self.textColor = .white
        super.drawText(in: rect)
    }
}
