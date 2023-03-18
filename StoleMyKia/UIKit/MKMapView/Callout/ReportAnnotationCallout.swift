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
    
    private let imageView = UIImageView(frame: .zero)
    private let titleView = UILabel(frame: .zero)
    private let subTitleView = UILabel(frame: .zero)
    private let colorTitleView = UILabel(frame: .zero)
    private let infoButton = UIButton(frame: .zero)
    
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
        setupImage()
        setupTitleView()
        setupSubtitleView()
        setupInfoButton()
    }
    
    func setupTitleView() {
        titleView.text = report.reportType.rawValue
        titleView.font = .boldSystemFont(ofSize: 16)
        
        addSubview(titleView)
        
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        titleView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 5).isActive = true
        titleView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    func setupSubtitleView() {
        subTitleView.text = "\(report.vehicleYear) \(report.vehicleMake.rawValue) Elantra"
        subTitleView.font = .systemFont(ofSize: 13)
        subTitleView.textColor = .gray
        subTitleView.textAlignment = .left

        addSubview(subTitleView)
        
        subTitleView.translatesAutoresizingMaskIntoConstraints = false
        subTitleView.topAnchor.constraint(equalTo: titleView.bottomAnchor).isActive = true
        subTitleView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 5).isActive = true
        subTitleView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

    }
    
    func setupImage() {
        imageView.image = UIImage.resizeImage(image: UIImage(named: "silvey")!, targetSize: .init(width: 75, height: 75))
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5
        addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    func setupInfoButton() {
        infoButton.setTitle("More Info", for: .normal)
        infoButton.titleLabel?.font = .systemFont(ofSize: 15)
        infoButton.setTitleColor(.red, for: .normal)
        infoButton.addTarget(self, action: #selector(isShowingReportInformationView), for: .touchUpInside)
        
        addSubview(infoButton)
        
        infoButton.frame = .init(x: 0, y: 0, width: 25, height: 5)
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        infoButton.leadingAnchor.constraint(equalTo: imageView.trailingAnchor).isActive = true
        infoButton.topAnchor.constraint(equalTo: subTitleView.bottomAnchor).isActive = true
        infoButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    @objc func isShowingReportInformationView() {
        calloutDelegate?.reportAnnotationWillPresentSheet()
    }
}
