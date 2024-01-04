//
//  ReportComposeViewModel.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 12/20/23.
//

import Foundation
import UIKit
import CoreLocation
import FirebaseAuth

enum NewReportError: String, Error {
    case locationError = "Please select a location"
    case userIdError = "You are not signed in. Please sign in to continue"
    case error = "We ran into an error when completing your request. Please try again."
    case detailIsEmpty = "Please enter details regarding your vehicle and the incident you are reporting"
}

final class ReportComposeViewModel: NSObject, ObservableObject {
    
    @Published var vehicleImage: UIImage?
    
    @Published var location: Location!
    
    @Published var reportType: ReportType = .stolen
    @Published var distinguishableDescription: String = ""
    
    @Published var vehicleYear: Int = 2011
    @Published var vehicleMake: VehicleMake = .hyundai
    @Published var vehicleModel: VehicleModel = .elantra
    @Published var vehicleColor: VehicleColor = .gray
    
    @Published var licensePlate: String = ""
    @Published var vin: String = ""
    
    @Published var doesNotHaveVehicleIdentification = false
     
    @Published var discloseLocation = true
    @Published var allowsForUpdates = true
    @Published var allowsForContact = false
    
    @Published var disablesLicensePlateAndVinSection = false
    
    @Published var isShowingBeSafeView = false
    @Published var isShowingWarningView = false
    @Published var isShowingReportDescriptionView = false
    @Published var isShowingImagePicker = false
    @Published var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary {
        didSet {
            isShowingImagePicker.toggle()
        }
    }
    
    @Published var isShowingPhotoRemoveConfirmation = false
    @Published var isUploading = false
    @Published var alertReason: NewReportError?
    @Published var alertErrorUploading = false
    @Published var alertSelectLocation = false
    
    var vehicleDescription: String {
        return "\(vehicleColor.rawValue) \(vehicleYear) \(vehicleMake.rawValue) \(vehicleModel.rawValue)"
    }
    
    
    var isNotSatisfied: Bool {
        guard (licensePlate.range(of: ".*[^A-Za-z0-9].*", options: .regularExpression) == nil), (vin.range(of: ".*[^A-Za-z0-9].*", options: .regularExpression) == nil)  else { return true }
        if !(self.vin.isEmpty) {
            if (self.vin.count >= 17) {
                if (doesNotHaveVehicleIdentification) {
                    return (self.distinguishableDescription.isEmpty || self.distinguishableDescription.count < Int.descriptionMinCharacterCount || self.distinguishableDescription.count > Int.descriptionMaxCharacterCount)
                } else {
                    return (self.licensePlate.isEmpty && self.vin.isEmpty)
                    || (self.distinguishableDescription.isEmpty || self.distinguishableDescription.count < Int.descriptionMinCharacterCount || self.distinguishableDescription.count > Int.descriptionMaxCharacterCount)
                }
            } else {
                return true
            }
        } else {
            if (doesNotHaveVehicleIdentification) {
                return (self.distinguishableDescription.isEmpty || self.distinguishableDescription.count < Int.descriptionMinCharacterCount || self.distinguishableDescription.count > Int.descriptionMaxCharacterCount)
            } else {
                return (self.licensePlate.isEmpty && self.vin.isEmpty)
                || (self.distinguishableDescription.isEmpty || self.distinguishableDescription.count < Int.descriptionMinCharacterCount || self.distinguishableDescription.count > Int.descriptionMaxCharacterCount)
            }
        }
    }
    
    
    func upload() {
        self.isUploading = true
        Task {
            do {
                guard let uid = Auth.auth().currentUser?.uid else {
                    throw NewReportError.userIdError
                }
                
                guard !(distinguishableDescription.isEmpty) else {
                    throw NewReportError.detailIsEmpty
                }
                
                var location: Location
                
                guard let userLocation = CLLocationManager.shared.usersCurrentLocation else {
                    throw NewReportError.locationError
                }
                
                if discloseLocation {
                    location = Location.disclose(lat: userLocation.latitude, long: userLocation.longitude)
                } else {
                    location = Location(coordinate: userLocation)
                }
                
                var vehicle = Vehicle(year: vehicleYear, make: vehicleMake, model: vehicleModel, color: vehicleColor)
                if !(licensePlate.isEmpty) {
                    try vehicle.licensePlateString(licensePlate)
                }
                if !(vin.isEmpty) {
                    try vehicle.vinString(vin)
                }
                var report = Report(uid: uid, type: reportType, Vehicle: vehicle, details: distinguishableDescription, location: location, discloseLocation: discloseLocation)
                
                report.allowsForUpdates = allowsForUpdates
                report.allowsForContact = allowsForContact
                
                guard let _ = try? await ReportManager.manager.upload(report, image: vehicleImage) else {
                    throw NewReportError.error
                }
                
                isUploading = false
            } catch NewReportError.locationError {
                self.isUploading = false
                self.alertSelectLocation.toggle()
            } catch {
                if let error = error as? NewReportError {
                    self.alertReason = error
                }
                self.isUploading = false
                self.alertErrorUploading = true
            }
        }
    }
}
