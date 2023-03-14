//
//  ReportAnnotationCallout.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/14/23.
//

import Foundation
import UIKit
import SwiftUI

class ReportAnnotationCallOut: UIView {
    
    private let titleView = UILabel(frame: .zero)
    private let infoButton = UIButton(frame: .zero)
    
    var report: Report!
    
    init(report: Report) {
        super.init(frame: .zero)
        self.report = report
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        setupTitleView()
        setupInfoButton()
    }
    
    func setupTitleView() {
        titleView.text = "Stolen Vehicle"
        addSubview(titleView)
        
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        titleView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        titleView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
    }
    
    func setupInfoButton() {
        infoButton.frame = .init(x: 0, y: 0, width: 75, height: 75)
        infoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        addSubview(infoButton)
        
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        
        infoButton.leadingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: 5).isActive = true
        infoButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        infoButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        infoButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}
