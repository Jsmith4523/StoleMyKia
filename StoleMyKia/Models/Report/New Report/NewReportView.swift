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
    
    @State private var vehicleMake: VehicleMake = .hyundai
    @State private var vehicleModel: VehicleModel = .accent
    @State private var vehicleYear: Int = 2011
    @State private var licensePlate: String = ""
    @State private var vin: String = ""
    
    @State private var doesNotHaveVehicleIdentification = false
    
    @State private var vehicleColor: VehicleColor = .black
    
    @State private var canUseUserLocation = true
    @State private var useCurrentLocation = true
    @State private var isShowingLocationView = false
    
    @State private var isShowingPhotoPicker = false
    @State private var isShowingPhotoRemoveConfirmation = false
    
    @State private var isUploading = false
    @State private var alertErrorUploading = false
    
    @EnvironmentObject var mapModel: MapViewModel
    @EnvironmentObject var reportsModel: ReportsViewModel
    
    @Environment (\.dismiss) var dismiss
    
    var isNotSatisfied: Bool {
        (self.licensePlate.isEmpty && self.vin.isEmpty) && !doesNotHaveVehicleIdentification
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
                    Picker("Vehicle...", selection: $reportType) {
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
                    Button("Select Location") {
                        isShowingLocationView.toggle()
                    }
                } header: {
                    Text("Location")
                } footer: {
                    Text("Depending on your location services settings, your current location will be applied as the location of this report")
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
                    //If the report type is stolen, the owner of the vehicle MUST include this information
                    Toggle("Not avaliable", isOn: $doesNotHaveVehicleIdentification)
                        .disabled(self.reportType == .stolen)
                    if !doesNotHaveVehicleIdentification {
                        TextField("License Plate", text: $licensePlate)
                        if (reportType == .stolen || reportType == .found) {
                            TextField("VIN", text: $vin)
                        }
                    }
                } header: {
                    Text("Vehicle Identification")
                } footer: {
                    if doesNotHaveVehicleIdentification {
                        Text("You do not have any information that could further identify the vehicle you're reporting\n\nNOTE: it might be more difficult to identify and locate the vehicle!")
                    } else {
                        if(reportType == .withnessed) {
                            Text("Enter the license plate number if noted.\n\nInformation entered is encrypted and cannot be read.")
                        } else {
                            Text("Enter the license plate number or the vehicle identification number (VIN) of the vehicle. Only one of the fields is required.\n\nInformation entered is encrypted and cannot be read.")
                        }
                    }
                }
                Section {
                    Button("Upload Photo") {
                        isShowingPhotoPicker.toggle()
                    }.disabled(!vehicleImage.isNil())
                } header: {
                    Text("Photo")
                } footer: {
                    Text("Include a photo you have of the vehicle. Do not include a photo of a license plate or other personal info found on the vehicle.")
                }
            }
            .navigationTitle("New Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isUploading {
                        ProgressView()
                    } else {
                        Button("Post") {
                            beginPostingReport()
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
            .onChange(of: vin) { _ in
                if vin.count > 17 {
                    self.vin = ""
                }
            }
            .onChange(of: licensePlate) { _ in
                if licensePlate.count > 8 {
                    self.licensePlate = ""
                }
            }
            .onChange(of: reportType) { type in
                if type == .withnessed {
                    vin = ""
                } else if type == .stolen {
                    doesNotHaveVehicleIdentification = false
                }
            }
            .onChange(of: doesNotHaveVehicleIdentification) { _ in
                self.vin = ""
                self.licensePlate = ""
            }
        }
        .interactiveDismissDisabled()
        .disabled(isUploading)
        .imagePicker(isPresented: $isShowingPhotoPicker, selectedImage: $vehicleImage, sourceType: .constant(.photoLibrary))
        .sheet(isPresented: $isShowingLocationView) {
            NewReportSearchLocation(location: $location)
                .environmentObject(mapModel)
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
        .onAppear {
            setUserLocation()
        }
    }
    
    private func setUserLocation() {
        guard mapModel.locationAuth.isAuthorized(), let userLocation = mapModel.userLocation else {
            return
        }
        
        let coords = userLocation.coordinate
        let usersLocation = Location(address: "", name: "", lat: coords.latitude, lon: coords.longitude)
        
        self.location = usersLocation
    }
    
    
    func beginPostingReport() {
        isUploading = true
        let generator = UINotificationFeedbackGenerator()
        let report = Report(dt: Date.now.epoch,
                            reportType: reportType,
                            vehicleYear: vehicleYear,
                            vehicleMake: vehicleMake,
                            vehicleColor: vehicleColor,
                            vehicleModel: vehicleModel,
                            licensePlate: EncryptedData.createEncryption(input: licensePlate),
                            vin: EncryptedData.createEncryption(input: vin),
                            distinguishable: "", location: location)
        reportsModel.upload(report, with: vehicleImage) { status in
            switch status {
            case true:
                generator.notificationOccurred(.success)
                self.isUploading = false
                dismiss()
            case false:
                generator.notificationOccurred(.error)
                alertErrorUploading.toggle()
                self.isUploading = false
            }
        }
    }
}

struct NewReportView_Previews: PreviewProvider {
    static var previews: some View {
        NewReportView()
            .environmentObject(ReportsViewModel())
            .environmentObject(MapViewModel())
    }
}
