//
//  ReportAnnotationCallout.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/14/23.
//

import Foundation
import UIKit
import SwiftUI

protocol RACalloutDelegate: AnyObject {
    func reportAnnotationWillPresentSheet()
}

class ReportAnnotationCallOut: UIView {
    
    private let titleView       = UILabel(frame: .zero)
    private let subTitleView    = UILabel(frame: .zero)
    private let colorTitleView  = UILabel(frame: .zero)
    private let infoButton      = UIButton(frame: .zero)
    
    var report: Report!
    
    weak var calloutDelegate: RACalloutDelegate?
    
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
        setupSubtitleView()
        setupInfoButton()
    }
    
    func setupTitleView() {
        if let reportType = report.reportType?.rawValue {
            titleView.text = reportType
            titleView.font = .systemFont(ofSize: 19, weight: .heavy)
        }
        
        addSubview(titleView)
        
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        titleView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        titleView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    func setupSubtitleView() {
        if let year = report.vehicleYear, let make = report.vehicleMake, let model = report.vehicleModel, let color = report.vehicleColor {
            subTitleView.text = "\(year) \(make.rawValue) \(model.rawValue) (\(color.rawValue))"
            subTitleView.font = .systemFont(ofSize: 13)
            subTitleView.textColor = .gray
            subTitleView.textAlignment = .left
            
            addSubview(subTitleView)
            
            subTitleView.translatesAutoresizingMaskIntoConstraints = false
            subTitleView.topAnchor.constraint(equalTo: titleView.bottomAnchor).isActive = true
            subTitleView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            subTitleView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        }
    }
    
    func setupInfoButton() {
        infoButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .regular)
        infoButton.setTitle("Details", for: .normal)
        infoButton.setTitleColor(.white, for: .normal)
        infoButton.clipsToBounds = true
        infoButton.layer.cornerRadius = 5
        infoButton.backgroundColor = .tintColor
        infoButton.addTarget(self, action: #selector(isShowingReportInformationView), for: .touchUpInside)

        addSubview(infoButton)

        infoButton.translatesAutoresizingMaskIntoConstraints = false
        infoButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        infoButton.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        infoButton.topAnchor.constraint(equalTo: subTitleView.bottomAnchor, constant: 7).isActive = true
        infoButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    @objc func isShowingReportInformationView() {
        calloutDelegate?.reportAnnotationWillPresentSheet()
    }
}
