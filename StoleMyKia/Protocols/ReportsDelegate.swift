//
//  ReportsDelegate.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 5/28/23.
//

import Foundation

protocol ReportsDelegate: AnyObject {
    func reportsDelegate(didReceieveReports reports: [Report])
    func reportsDelegate(didDeleteReport report: Report)
}

protocol SelectedReportAnnotationDelegate: AnyObject {
    func didSelectReport(_ report: Report)
    func didSelectCluster(_ reports: [Report])
}
