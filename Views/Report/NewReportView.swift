//
//  NewReportView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/13/23.
//

import SwiftUI
import UIKit
import CoreLocation

//TODO: Picker: the selection "" is invalid and does not have an associated tag, this will give undefined results. Not sure how to fix...

struct NewReportView: View {
    
    enum NewReportError: String, Error {
        case locationError = "Please select a location"
        case userIdError = "Something went wrong. You do not appear to be signed in. Please contact the developer!"
        case error = "We ran into an error when completing your request. Please try again."
        case detailIsEmpty = "Please enter details regarding your vehicle and the incident you are reporting"
    }
    
    @State private var vehicleImage: UIImage?
    
    @State private var location: Location!
    
    @State private var reportType: ReportType = .stolen
    @State private var distinguishableDescription: String = ""
    
    @State private var vehicleYear: Int = 2011
    @State private var vehicleMake: VehicleMake = .hyundai
    @State private var vehicleModel: VehicleModel = .elantra
    @State private var vehicleColor: VehicleColor = .gray
    @State private var licensePlate: String = ""
    
    @State private var doesNotHaveVehicleIdentification = false
        
    @State private var canUseUserLocation = true
    @State private var useCurrentLocation = true
    @State private var isShowingLocationView = false
    @State private var disablesLicensePlateAndVinSection = false
    
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
        guard (licensePlate.range(of: ".*[^A-Za-z0-9].*", options: .regularExpression) == nil) else { return true }
        if (doesNotHaveVehicleIdentification) {
            return (self.distinguishableDescription.isEmpty || self.distinguishableDescription.count < 19 || self.distinguishableDescription.count > 301)
        } else {
            return (self.licensePlate.isEmpty || self.licensePlate.count < 6)
            || (self.distinguishableDescription.isEmpty || self.distinguishableDescription.count < 19 || self.distinguishableDescription.count > 301)
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
                        ForEach(ReportType.reports, id: \.rawValue) {
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
                            .tint(.brand)
                        if !doesNotHaveVehicleIdentification {
                            TextField("License Plate", text: $licensePlate)
                                .keyboardType(.alphabet)
                                .submitLabel(.done)
                        }
                    } header: {
                        Text("Vehicle Identification")
                    } footer: {
                        if doesNotHaveVehicleIdentification {
                            Text("Note that the difficulty of identifying the vehicle may vary based on the information you have included with this report. Please make sure information is accurate.")
                        } else {
                            Text("Please enter the vehicle's full license plate. Do not include any spaces or special characters. Maximum characters allowed is 8.")
                        }
                    }
                }
                
                Section {
                    TextEditor(text: $distinguishableDescription)
                } header: {
                    Text("Distinguishable Details")
                } footer: {
                    Text("Describe the incident and include any distinguishable details of the vehicle in the field above. \n\nCharacter limit: 20-400 characters.")
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
                
                Section {
                    Button("Nearby Locations") {
                        isShowingLocationView.toggle()
                    }
                } header: {
                    Text("Report Location")
                } footer: {
                    Text("Depending on your location services settings, your current location has been applied to this report. You can select a nearby location if possible.")
                }
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
            //Remedying the picker warning xcode throws when chaging either a vehicle make or year...
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
            .onChange(of: doesNotHaveVehicleIdentification) { _ in
                self.licensePlate = ""
            }
            .onChange(of: reportType) { type in
                if type.disableLicenseAndVinInformation {
                    self.disablesLicensePlateAndVinSection = true
                    self.doesNotHaveVehicleIdentification = true
                } else {
                    self.disablesLicensePlateAndVinSection = false
                    self.doesNotHaveVehicleIdentification = false
                }
                
                if type.requiresLicensePlateInformation {
                    self.doesNotHaveVehicleIdentification = false
                }
            }
        }
        .interactiveDismissDisabled()
        .tint(Color(uiColor: .label))
        .disabled(isUploading)
        .customSheetView(isPresented: $isShowingLocationView, detents: [.large()], showsIndicator: true) {
            NearbyLocationSearchView(location: $location)
        }
        .sheet(isPresented: $isShowingImagePicker) {
            PhotoPicker(selectedImage: $vehicleImage, source: imagePickerSourceType)
                .ignoresSafeArea()
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
        .alert("Location not selected", isPresented: $alertSelectLocation) {
            Button("OK") { isShowingLocationView.toggle()}
        } message: {
            Text("Please select a location")
        }
    }
    
    ///Retrieves the current location of the user
    private func usersLocation() -> Location? {
        guard let userLocation = CLLocationManager.shared.usersCurrentLocation, (self.location == nil) else {
            return nil
        }
        
        return Location(coordinates: userLocation)
    }
    
    private func upload() {
        do {
            self.isUploading = true
            
            guard let uid = userVM.uid else {
                throw NewReportError.userIdError
            }
            
            guard !(distinguishableDescription.isEmpty) else {
                throw NewReportError.detailIsEmpty
            }
                        
            guard let location = usersLocation() ?? location else {
                throw NewReportError.locationError
            }
            
            var vehicle = Vehicle(year: vehicleYear, make: vehicleMake, model: vehicleModel, color: vehicleColor)
            try vehicle.licensePlateString(licensePlate)
            let report = Report(uid: uid, type: reportType, Vehicle: vehicle, details: distinguishableDescription, location: location)
            
            Task {
                guard let _ = try? await reportsVM.uploadReport(report, image: vehicleImage) else {
                    throw NewReportError.error
                }
                DispatchQueue.main.async {
                    dismiss()
                }
            }
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

struct NewReportView_Previews: PreviewProvider {
    static var previews: some View {
        NewReportView()
            .environmentObject(ReportsViewModel())
            .environmentObject(UserViewModel())
            .tint(Color(uiColor: .label))
    }
}
