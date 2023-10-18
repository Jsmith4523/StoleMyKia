//
//  NewReportView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/13/23.
//

import SwiftUI
import UIKit
import CoreLocation
import FirebaseAuth

//TODO: Picker: the selection "" is invalid and does not have an associated tag, this will give undefined results. Not sure how to fix...

enum NewReportError: String, Error {
    case locationError = "Please select a location"
    case userIdError = "You are not signed in. Please sign in to continue"
    case error = "We ran into an error when completing your request. Please try again."
    case detailIsEmpty = "Please enter details regarding your vehicle and the incident you are reporting"
}

struct NewReportView: View {
    
    @State private var vehicleImage: UIImage?
    
    @State private var location: Location!
    
    @State private var reportType: ReportType = .stolen
    @State private var distinguishableDescription: String = ""
    
    @State private var vehicleYear: Int = 2011
    @State private var vehicleMake: VehicleMake = .hyundai
    @State private var vehicleModel: VehicleModel = .elantra
    @State private var vehicleColor: VehicleColor = .gray
    
    @State private var licensePlate: String = ""
    @State private var vin: String = ""
    
    @State private var doesNotHaveVehicleIdentification = false
        
    @State private var discloseLocation = false
    @State private var allowsForUpdates = true
    @State private var allowsForContact = false
    
    @State private var disablesLicensePlateAndVinSection = false
    
    @State private var isShowingReportDescriptionView = false
    @State private var isShowingImagePicker = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary {
        didSet {
            isShowingImagePicker.toggle()
        }
    }
    
    
    @State private var isShowingPhotoRemoveConfirmation = false
        
    @State private var isUploading = false
    @State private var alertReason: NewReportError?
    @State private var alertErrorUploading = false
    @State private var alertSelectLocation = false
    
    @EnvironmentObject var reportsVM: ReportsViewModel
    @EnvironmentObject var userVM: UserViewModel
    
    @Environment (\.dismiss) var dismiss
    
    var isNotSatisfied: Bool {
        guard (licensePlate.range(of: ".*[^A-Za-z0-9].*", options: .regularExpression) == nil), (vin.range(of: ".*[^A-Za-z0-9].*", options: .regularExpression) == nil)  else { return true }
        if (doesNotHaveVehicleIdentification) {
            return (self.distinguishableDescription.isEmpty || self.distinguishableDescription.count < Int.descriptionMinCharacterCount || self.distinguishableDescription.count > Int.descriptionMaxCharacterCount)
        } else {
            return (self.licensePlate.isEmpty && self.vin.isEmpty)
            || (self.distinguishableDescription.isEmpty || self.distinguishableDescription.count < Int.descriptionMinCharacterCount || self.distinguishableDescription.count > Int.descriptionMaxCharacterCount)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                if let vehicleImage {
                    HStack {
                        Spacer()
                        Image(uiImage: vehicleImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .onTapGesture {
                                isShowingPhotoRemoveConfirmation.toggle()
                            }
                        Spacer()
                    }
                }
                Section {
                    Picker("Type", selection: $reportType) {
                        ForEach(ReportType.allCases, id: \.rawValue) {
                            Text($0.rawValue)
                                .tag($0)
                        }
                    }
                } header: {
                    Text("Report Type")
                } footer: {
                    Text(reportType.description)
                }
                
                Section {
                    Toggle("Hide Location", isOn: $discloseLocation)
                        .tint(.green)
                    Toggle("Allow For Updates", isOn: $allowsForUpdates)
                        .tint(.green)
                    Toggle("Contact Me", isOn: $allowsForContact)
                } header: {
                    Text("Options")
                }
                
                Section {
                    Picker("Year", selection: $vehicleYear) {
                        ForEach(vehicleModel.year, id: \.self) {
                            Text(String($0))
                                .tag($0)
                        }
                    }
                    Picker("Make", selection: $vehicleMake) {
                        ForEach(VehicleMake.allCases, id: \.self) {
                            Text($0.rawValue)
                                .tag($0)
                        }
                    }
                    .tag(vehicleMake)
                    Picker("Model", selection: $vehicleModel) {
                        ForEach(VehicleModel.allCases.filter(self.vehicleMake, self.vehicleYear), id: \.self) {
                            Text($0.rawValue)
                                .tag($0)
                        }
                    }
                    Picker("Color", selection: $vehicleColor) {
                        ForEach(VehicleColor.allCases, id: \.rawValue) {
                            Text($0.rawValue)
                                .tag($0)
                        }
                    }
                } header: {
                    Text("Vehicle Information")
                }
                
                if !disablesLicensePlateAndVinSection {
                    Section {
                        Toggle("Not avaliable", isOn: $doesNotHaveVehicleIdentification)
                            .disabled(self.reportType.requiresLicensePlateInformation)
                            .tint(.green)
                        if !doesNotHaveVehicleIdentification {
                            TextField("License Plate", text: $licensePlate)
                                .keyboardType(.alphabet)
                                .submitLabel(.done)
                            TextField("VIN", text: $vin)
                                .keyboardType(.alphabet)
                                .submitLabel(.done)
                        }
                    } header: {
                        Text("Vehicle Identification")
                    } footer: {
                        if doesNotHaveVehicleIdentification {
                            Text("Difficulty identify this vehicle may vary!")
                        } else {
                            Text("Please enter the vehicles full license plate and/or VIN. Depending on the report type, at least one field is required. Do not include any spaces or special characters.")
                        }
                    }
                }
                
                Section {
                    Button("Add Description") {
                        isShowingReportDescriptionView.toggle()
                    }
                } header: {
                    Text("Description")
                } footer: {
                    Text("Describe your situation.")
                }
                
                Section {
                    Button("Select Photo") {
                        imagePickerSourceType = .photoLibrary
                    }
                    Button("Take Photo") {
                        imagePickerSourceType = .camera
                    }
                } header: {
                    Text("Photo")
                } footer: {
                    Text("Include an image you have of the vehicle that would properly distinguish it from others.")
                }
                .disabled(!vehicleImage.isNil())
            }
            .navigationTitle("New Report")
            .navigationBarTitleDisplayMode(.inline)
            .autocorrectionDisabled()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .bold()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isUploading {
                        ProgressView()
                    } else {
                        Button {
                            upload()
                        } label: {
                            Text("Upload")
                                .bold()
                        }
                        .disabled(isNotSatisfied)
                    }
                }
            }
            //Remedying the picker warning Xcode throws when changing either a vehicle make or year...
            .onChange(of: vehicleMake) { _ in
                self.vehicleModel = vehicleModel.matches(make: self.vehicleMake, year: self.vehicleYear)
            }
            .onChange(of: vehicleYear) { _ in
                self.vehicleModel = vehicleModel.matches(make: self.vehicleMake, year: self.vehicleYear)
            }
            .onChange(of: licensePlate) { _ in
                if licensePlate.count > 8 {
                    self.licensePlate = ""
                }
            }
            .onChange(of: vin) { _ in
                if vin.count > 17 {
                    self.vin = ""
                }
            }
            .onChange(of: doesNotHaveVehicleIdentification) { _ in
                self.licensePlate = ""
                self.vin = ""
            }
            .onChange(of: reportType) { type in
                if type.requiresLicensePlateInformation {
                    self.doesNotHaveVehicleIdentification = false
                }
            }
        }
        .interactiveDismissDisabled()
        .tint(Color(uiColor: .label))
        .disabled(isUploading)
        .fullScreenCover(isPresented: $isShowingImagePicker) {
            PhotoPicker(selectedImage: $vehicleImage, source: imagePickerSourceType)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $isShowingReportDescriptionView) {
            ReportDescriptionView(description: $distinguishableDescription)
        }
        .confirmationDialog("", isPresented: $isShowingPhotoRemoveConfirmation) {
            Button("Remove", role: .destructive) {
                vehicleImage = nil
            }
        } message: {
            Text("Remove Image?")
        }
        .alert("Unable to upload", isPresented: $alertErrorUploading) {
            Button("OK") {}
        } message: {
            Text(alertReason?.rawValue ?? "We ran into a problem completing that request. Please try again")
        }
        .alert("Your location could not be retrieved at the moment", isPresented: $alertSelectLocation) {
            Button("OK") { }
        } message: {
            Text("Please try again once location services are enabled and your device connection is stable.")
        }
    }
    
    @MainActor
    private func upload() {
        Task {
            do {
                self.isUploading = true
                
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
                
                guard let _ = try? await reportsVM.uploadReport(report, image: vehicleImage) else {
                    throw NewReportError.error
                }
                
                dismiss()
                
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

struct NewReportView_Previews: PreviewProvider {
    static var previews: some View {
        NewReportView()
            .environmentObject(ReportsViewModel())
            .environmentObject(UserViewModel())
            .tint(Color(uiColor: .label))
    }
}
