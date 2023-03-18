//
//  NewReportView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/13/23.
//

import SwiftUI
import UIKit

struct NewReportView: View {
    
    @State private var vehicleImage: UIImage?
    
    @State private var reportType: ReportType = .stolen
    @State private var reportDescription: String = ""
    
    @State private var vehicleMake: VehicleMake = .hyundai
    @State private var vehicleModel: VehicleModel = .accent
    @State private var vehicleYear: Int = 2011
    
    @State private var vehicleColor: VehicleColor = .black
    @State private var vehicleDescription: String = ""
    
    @State private var source: UIImagePickerController.SourceType = .camera
    @State private var isShowingPhotoPicker = false
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker("Report type", selection: $reportType) {
                        ForEach(ReportType.allCases, id: \.rawValue) {
                            Text($0.rawValue)
                                .tag($0)
                        }
                    }
                    .font(.system(size: 16))
                } header: {
                    Text("Report Type")
                }
                Section {
                    TextEditor(text: $reportDescription)
                } header: {
                    Text("Report Description (Input below)")
                }
                Section {
                    Picker("Year", selection: $vehicleYear) {
                        ForEach(Report.affectedVehicleYears, id: \.self) {
                            Text(String($0))
                                .tag($0)
                        }
                    }
                    Picker("Make", selection: $vehicleMake) {
                        ForEach(VehicleMake.allCases, id: \.rawValue) {
                            Text($0.rawValue)
                                .tag($0)
                        }
                    }
                    Picker("Model", selection: $vehicleModel) {
                        ForEach(VehicleModel.allCases.filter(self.vehicleMake, self.vehicleYear), id: \.rawValue) {
                            Text($0.rawValue)
                                .tag($0)
                        }
                    }
                } header: {
                    Text("Vehicle Information")
                }
                Section {
                    Picker("Vehicle Color", selection: $vehicleColor) {
                        ForEach(VehicleColor.allCases, id: \.rawValue) {
                            Text($0.rawValue)
                                .tag($0)
                        }
                    }
                } header: {
                    Text("Appearance")
                }
                Section {
                    TextEditor(text: $vehicleDescription)
                } header: {
                    Text("Appearance Description (Input below)")
                }
            }
            .navigationTitle("New Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
            }
        }
        .accentColor(.accentColor)
        .interactiveDismissDisabled()
        .imagePicker(isPresented: $isShowingPhotoPicker, selectedImage: $vehicleImage, sourceType: $source)
    }
}

struct NewReportView_Previews: PreviewProvider {
    static var previews: some View {
        NewReportView()
            .accentColor(.red)
    }
}
