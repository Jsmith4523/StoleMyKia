//
//  LicenseScannerDelegate.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/10/23.
//

import Foundation

enum LicenseScannerError: String, Error {
    case noReports = "There are no active reports for that license plate."
    case networkError = "There was an error finding reports that contain that license plate."
}

protocol LicenseScannerDelegate: AnyObject {
    func getReportsWithLicense(_ licenseString: String, completion: @escaping ((Result<[Report], LicenseScannerError>)->Void))
}
