//
//  TimelineAnnotationViewCallout.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 7/11/23.
//

import UIKit

protocol TimelineAnnotationViewCalloutDelegate: AnyObject {
    //When the users presses the information button, this method will call
    //and a sheet will present the report they've selected.
    func didSelectReport(_ report: Report)
}

class TimelineAnnotationViewCallout: UIView {
    
    private var reportTypeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        return label
    }()
    
    private var reportDateTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        return label
    }()
    
    private var reportRoleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        return label
    }()
    
    private var detailButton: UIButton = {
        let button = UIButton()
        button.tintColor = .systemBlue
        button.setImage(UIImage(systemName: "info.circle"), for: .normal)
        return button
    }()
        
    private var isSelectedReport: Bool
    private var report: Report
    
    private var onSelect: (Report) -> Void
    
    init(report: Report, selectedReportId: UUID, onSelect: @escaping (Report) -> ()) {
        self.report                     = report
        self.isSelectedReport           = report.id == selectedReportId
        self.onSelect                   = onSelect
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        reportTypeLabel.text = report.reportType.rawValue
        reportDateTimeLabel.text = report.dt.full
        reportRoleLabel.text = "Type: \(report.role.title)"
        
        detailButton.addTarget(self, action: #selector(presentReportDetailView), for: .touchUpInside)
        
        addSubview(reportTypeLabel)
        addSubview(reportDateTimeLabel)
        addSubview(reportRoleLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        reportTypeLabel.translatesAutoresizingMaskIntoConstraints     = false
        reportDateTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        reportRoleLabel.translatesAutoresizingMaskIntoConstraints     = false
        
        if !isSelectedReport {
            setupWithButton()
        } else {
            setupWithoutButton()
        }
        
        func setupWithoutButton() {
            NSLayoutConstraint.activate([
                reportTypeLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
                reportTypeLabel.topAnchor.constraint(equalTo: topAnchor),
                reportTypeLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
                
                reportDateTimeLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
                reportDateTimeLabel.topAnchor.constraint(equalTo: reportTypeLabel.bottomAnchor, constant: 3),
                reportDateTimeLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
                
                
                reportRoleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
                reportRoleLabel.topAnchor.constraint(equalTo: reportDateTimeLabel.bottomAnchor),
                reportRoleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
                reportRoleLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
        }
        
        func setupWithButton() {
            addSubview(detailButton)
            
            detailButton.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                reportTypeLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
                reportTypeLabel.topAnchor.constraint(equalTo: topAnchor),
                
                reportDateTimeLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
                reportDateTimeLabel.topAnchor.constraint(equalTo: reportTypeLabel.bottomAnchor, constant: 3),
                reportDateTimeLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
                
                reportRoleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
                reportRoleLabel.topAnchor.constraint(equalTo: reportDateTimeLabel.bottomAnchor),
                reportRoleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
                reportRoleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
                
                detailButton.topAnchor.constraint(equalTo: topAnchor),
                detailButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            ])
        }
    }
    
    @objc private func presentReportDetailView() {
        self.onSelect(report)
    }
}
