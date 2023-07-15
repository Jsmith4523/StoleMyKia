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

protocol LicensePlateCoordinatorDelegate: AnyObject {
    ///Fetches reports that contain license plate information.
    ///- Parameters:
    ///   - licenseString: The string value of a license plate text from VisionKit
    ///
    /// - Returns: Reports that exactly matches the license string.
    ///
    /// - Throws: Error if reports could not be fetched 
    func fetchReportsWithLicense(_ licenseString: String) async throws -> [Report]
}
