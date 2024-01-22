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

struct ReportComposeView: View {
    
    @EnvironmentObject var composeVM: ReportComposeViewModel
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        Form {
            if let vehicleImage = composeVM.vehicleImage {
                HStack {
                    Spacer()
                    Image(uiImage: vehicleImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .onTapGesture {
                            composeVM.isShowingPhotoRemoveConfirmation.toggle()
                        }
                    Spacer()
                }
            }
            Section("Details") {
                LabeledContent("Report Type", value: composeVM.reportType.rawValue)
                LabeledContent("Vehicle", value: composeVM.vehicleDescription)
                NavigationLink("Edit Details") {
                    ReportComposeEditVehicleView()
                        .environmentObject(composeVM)
                }
                .foregroundColor(.blue)
            }
            
            Section {
                Toggle("Hide Location", isOn: $composeVM.discloseLocation)
                Toggle("Allow For Updates", isOn: $composeVM.allowsForUpdates)
                Toggle("Contact Me", isOn: $composeVM.allowsForContact)
            } header: {
                Text("Options")
            }
            .tint(.blue)
            
            if !composeVM.disablesLicensePlateAndVinSection {
                Section {
                    Toggle("Not avaliable", isOn: $composeVM.doesNotHaveVehicleIdentification)
                        .disabled(composeVM.reportType.requiresLicensePlateInformation)
                        .tint(.blue)
                    if !composeVM.doesNotHaveVehicleIdentification {
                        TextField("License Plate", text: $composeVM.licensePlate)
                            .keyboardType(.alphabet)
                            .submitLabel(.done)
                        TextField("VIN", text: $composeVM.vin)
                            .keyboardType(.alphabet)
                            .submitLabel(.done)
                    }
                } header: {
                    Text("Vehicle Identification")
                } footer: {
                    if composeVM.doesNotHaveVehicleIdentification {
                        Text("There is no license plate and/or VIN available.")
                    } else {
                        Text("Enter the vehicle's full license plate and/or VIN. Depending on the report type, at least one field is required.\n\nIncluding a VIN will require users to verify the VIN in order to update or contact you (if enabled) regarding your report. \n\nIncluding a license plate will only require users to verify based upon their distance from the location of this report.")
                    }
                }
            }
            
            Section {
                Button("Add Description") {
                    composeVM.isShowingReportDescriptionView.toggle()
                }
            } header: {
                Text("Description")
            } footer: {
                Text("Please describe your situation.")
            }
            
            Section {
                Button("Select Photo") {
                    composeVM.imagePickerSourceType = .photoLibrary
                }
                Button("Take Photo") {
                    composeVM.imagePickerSourceType = .camera
                }
            } header: {
                Text("Photo")
            } footer: {
                Text("Please include an appropriate and identifiable image of the vehicle.")
            }
            .disabled(!composeVM.vehicleImage.isNil())
        }
        .interactiveDismissDisabled(composeVM.isUploading)
        .navigationTitle("New Report")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(composeVM.isUploading)
        .autocorrectionDisabled()
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    composeVM.isShowingBeSafeView.toggle()
                } label: {
                    Image(systemName: "checkerboard.shield")
                        .foregroundColor(.green)
                }
                
                if composeVM.isUploading {
                    ProgressView()
                } else {
                    Button {
                        composeVM.isShowingWarningView.toggle()
                    } label: {
                        Text("Upload")
                            .bold()
                    }
                    .disabled(composeVM.isNotSatisfied)
                }
            }
        }
        .onChange(of: composeVM.licensePlate) { _ in
            if composeVM.licensePlate.count > 8 {
                composeVM.licensePlate = ""
            }
        }
        .onChange(of: composeVM.vin) { _ in
            if composeVM.vin.count > 17 {
                composeVM.vin = ""
            }
        }
        .onChange(of: composeVM.doesNotHaveVehicleIdentification) { _ in
            composeVM.licensePlate = ""
            composeVM.vin = ""
        }
        .onAppear {
            if composeVM.reportType.requiresLicensePlateInformation {
                composeVM.doesNotHaveVehicleIdentification = false
            }
        }
        .tint(Color(uiColor: .label))
        .disabled(composeVM.isUploading)
        .fullScreenCover(isPresented: $composeVM.isShowingImagePicker) {
            PhotoPicker(selectedImage: $composeVM.vehicleImage, source: composeVM.imagePickerSourceType)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $composeVM.isShowingReportDescriptionView) {
            ReportComposeDescriptionView(description: $composeVM.distinguishableDescription)
        }
        .sheet(isPresented: $composeVM.isShowingWarningView) {
            ReportComposeReminderView(postCompletion: upload)
        }
        .fullScreenCover(isPresented: $composeVM.isShowingBeSafeView) {
            SafetyView()
        }
        .confirmationDialog("", isPresented: $composeVM.isShowingPhotoRemoveConfirmation) {
            Button("Remove", role: .destructive) {
                composeVM.vehicleImage = nil
            }
        } message: {
            Text("Remove Image?")
        }
        .alert("Unable to upload", isPresented: $composeVM.alertErrorUploading) {
            Button("OK") {}
        } message: {
            Text(composeVM.alertReason?.rawValue ?? "We ran into a problem completing that request. Please try again")
        }
        .alert("Your location could not be retrieved at the moment", isPresented: $composeVM.alertSelectLocation) {
            Button("Location Settings") { URL.openApplicationSettings() }
            Button("OK") { }
        } message: {
            Text("Please try again once location services are enabled and your device connection is stable.")
        }
    }
    
    private func upload() {
        composeVM.upload()
    }
}

struct NewReportView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ReportComposeView()
                .environmentObject(ReportsViewModel())
                .environmentObject(UserViewModel())
                .environmentObject(ReportComposeViewModel())
        }
    }
}
