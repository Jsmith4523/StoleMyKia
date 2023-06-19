//
//  NewReportView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/13/23.
//

import SwiftUI
import UIKit

//TODO: Picker: the selection "" is invalid and does not have an associated tag, this will give undefined results. Not sure how to fix...

struct NewReportView: View {
    
    @State private var vehicleImage: UIImage?
    
    @State private var location: Location!
    
    @State private var reportType: ReportType = .stolen
    @State private var reportDescription: String = ""
    
    @State private var vehicleYear: Int = 2011
    @State private var vehicleMake: VehicleMake = .hyundai
    @State private var vehicleModel: VehicleModel = .accent
    @State private var vehicleColor: VehicleColor = .black
    @State private var licensePlate: String = ""
    
    @State private var doesNotHaveVehicleIdentification = false
        
    @State private var canUseUserLocation = true
    @State private var useCurrentLocation = true
    @State private var isShowingLocationView = false
    
    @State private var isShowingImagePicker = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary {
        didSet {
            isShowingImagePicker.toggle()
        }
    }
    @State private var isShowingPhotoRemoveConfirmation = false
        
    @State private var isUploading = false
    @State private var alertErrorUploading = false
    @State private var alertSelectLocation = false
    
    @EnvironmentObject var reportsModel: ReportsViewModel
    
    @Environment (\.dismiss) var dismiss
    
    var isNotSatisfied: Bool {
        (self.licensePlate.isEmpty) && !doesNotHaveVehicleIdentification
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
                            .frame(width: 100, height: 100)
                            .onTapGesture {
                                isShowingPhotoRemoveConfirmation.toggle()
                            }
                        Spacer()
                    }
                }
                Section {
                    Picker("Reporting...", selection: $reportType) {
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
                    Button("Upload Photo") {
                        imagePickerSourceType = .photoLibrary
                    }
                    Button("Take Photo") {
                        imagePickerSourceType = .camera
                    }
                } header: {
                    Text("Photo")
                } footer: {
                    Text("Include a photo you have of the vehicle. Try not to include a photo of the license plate or other personal info found on the vehicle.")
                }
                .disabled(!vehicleImage.isNil())
                
                Section {
                    Button("Select Location") {
                        isShowingLocationView.toggle()
                    }
                } header: {
                    Text("Report Location")
                } footer: {
                    Text("Depending on your location services settings, your current location has been applied to this report.")
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
                
                Section {
                    Toggle("Not avaliable", isOn: $doesNotHaveVehicleIdentification)
                        .disabled(self.reportType.requiresLicensePlateInformation)
                    if !doesNotHaveVehicleIdentification {
                        TextField("License Plate", text: $licensePlate)
                    }
                } header: {
                    Text("Vehicle Identification")
                } footer: {
                    if doesNotHaveVehicleIdentification {
                        Text("You do not have any information that could further identify the vehicle you're reporting\n\nNOTE: it might be more difficult to identify the vehicle")
                    } else {
                        Text("Enter the license plate number if noted.\n\nInformation entered is encrypted and cannot be read.")
                    }
                }
            }
            .navigationTitle("New Report")
            .navigationBarTitleDisplayMode(.inline)
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
            .tint(.accentColor)
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
                if type.requiresLicensePlateInformation {
                    self.doesNotHaveVehicleIdentification = false
                }
            }
        }
        .interactiveDismissDisabled()
        .disabled(isUploading)
        
        .sheet(isPresented: $isShowingLocationView) {
            LocationSearchView(location: $location)
        }
        .sheet(isPresented: $isShowingImagePicker) {
            PhotoPicker(selectedImage: $vehicleImage, source: imagePickerSourceType)
        }
        .confirmationDialog("", isPresented: $isShowingPhotoRemoveConfirmation) {
            Button("Remove", role: .destructive) {
                vehicleImage = nil
            }
        } message: {
            Text("Remove Image?")
        }
        .alert("Error uploading report", isPresented: $alertErrorUploading) {
            Button("OK") {}
        } message: {
            Text("There was a problem uploading your report. Please try again later")
        }
        .alert("Location not selected", isPresented: $alertSelectLocation) {
            Button("OK") { isShowingLocationView.toggle()}
        } message: {
            Text("Please select a location")
        }
    }
    
    //Retrieving the users locations...
    private func usersLocation() -> Location? {
//        guard mapModel.locationAuth.isAuthorized(), let userLocation = mapModel.userLocation else {
//            return nil
//        }
//
//        let coords = userLocation.coordinate
//        let usersLocation = Location(address: "", name: "", lat: coords.latitude, lon: coords.longitude)
//
//        return usersLocation
        //TODO: Get the users location
        return nil
    }
    
    
    private func upload() {
        isUploading = true
        
        if location.isNil() {
            if let userLocation = usersLocation() {
                self.location = userLocation
            }
        }
           
        guard let location else {
            alertSelectLocation.toggle()
            isUploading = false
            return
        }
        
        let vehicle = Vehicle(vehicleYear: vehicleYear, vehicleMake: vehicleMake, vehicleColor: vehicleColor, vehicleModel: vehicleModel)
        var report = Report(dt: Date.now.epoch,
                            reportType: reportType,
                            vehicle: vehicle,
                            distinguishable: "",
                            location: location, role: .original)
        
        do {
            try report.setLicensePlate(licensePlate)
        } catch {
            alertErrorUploading.toggle()
        }
        
        reportsModel.upload(report, with: vehicleImage) { success in
            guard success else {
                self.alertErrorUploading.toggle()
                self.isUploading = false
                return
            }
            dismiss()
        }
    }
}

struct NewReportView_Previews: PreviewProvider {
    static var previews: some View {
        NewReportView()
            .environmentObject(ReportsViewModel())
    }
}
