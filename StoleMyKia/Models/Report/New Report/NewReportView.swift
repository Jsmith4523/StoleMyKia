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
    
    @State private var reportType: ReportType = .stolen
    @State private var reportDescription: String = ""
    
    @State private var vehicleMake: VehicleMake = .hyundai
    @State private var vehicleModel: VehicleModel = .accent
    @State private var vehicleYear: Int = 2011
    @State private var licensePlate: String = ""
    @State private var vin: String = ""
    
    @State private var vehicleColor: VehicleColor = .black
    
    @State private var isShowingPhotoPicker = false
    @State private var isShowingPhotoRemoveConfirmation = false
    
    @Environment (\.dismiss) var dismiss
    
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
                    Picker("Year", selection: $vehicleYear) {
                        ForEach(Report.affectedVehicleYears, id: \.self) {
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
                    TextField("License Plate", text: $licensePlate)
                    if (reportType == .stolen || reportType == .found) {
                        TextField("VIN", text: $vin)
                    }
                } header: {
                    Text("Vehicle Identification")
                } footer: {
                    if(reportType == .withnessed) {
                        Text("Enter the license plate number if noted.")
                    } else {
                        Text("Enter the license plate number or the vehicle identification number (VIN) of the vehicle. Only one of the fields is required.")
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
                    NavigationLink {
                        
                    } label: {
                        Text("Next")
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
        }
        .interactiveDismissDisabled()
        .imagePicker(isPresented: $isShowingPhotoPicker, selectedImage: $vehicleImage, sourceType: .constant(.photoLibrary))
        .confirmationDialog("", isPresented: $isShowingPhotoRemoveConfirmation) {
            Button("Remove", role: .destructive) {
                vehicleImage = nil
            }
        } message: {
            Text("Remove Image?")
        }
    }
}

struct NewReportView_Previews: PreviewProvider {
    static var previews: some View {
        NewReportView()
    }
}
