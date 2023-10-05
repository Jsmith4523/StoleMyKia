//
//  UpdateReportView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/1/23.
//

import SwiftUI
import CoreLocation
import FirebaseAuth

enum ImagePickerSource: String, Identifiable, CaseIterable {
    case camera = "Take Photo"
    case photoLibrary = "Photo Library"
    
    var id: String {
        self.rawValue
    }
    
    var sourceType: UIImagePickerController.SourceType {
        switch self {
        case .camera:
            return .camera
        case .photoLibrary:
            return .photoLibrary
        }
    }
}

struct UpdateReportView: View {
    
    let originalReport: Report
    
    @State private var isUploading = false
    @State private var isShowingDescriptionView = false
    @State private var isShowingLocationSearchView = false
    
    @State private var presentError = false
    
    @State private var vehicleImage: UIImage?
    @State private var description: String = ""
    @State private var updateReportType: ReportType = .found
    
    @State private var photoPickerSourceType: UIImagePickerController.SourceType?
    
    @State private var location: Location?
    
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var reportsVM: ReportsViewModel
    
    @Environment (\.dismiss) var dismiss
        
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Text("Vehicle")
                        Spacer()
                        Text(originalReport.vehicleDetails)
                            .font(.system(size: 17))
                            .foregroundColor(.gray)
                    }
                    if originalReport.hasLicensePlate {
                        HStack {
                            Text("License")
                            Spacer()
                            Text(originalReport.vehicle.licensePlateString)
                                .font(.system(size: 17))
                                .foregroundColor(.gray)
                        }
                    }
                    if originalReport.hasVin {
                        HStack {
                            Text("VIN")
                            Spacer()
                            Text(originalReport.vehicle.vinString)
                                .font(.system(size: 17))
                                .foregroundColor(.gray)
                        }
                    }
                    HStack {
                        Text("Report Details: \n\n\(originalReport.distinguishableDetails)")
                            .font(.system(size: 17))
                            .lineLimit(4)
                            .foregroundColor(.gray)
                    }
                } header: {
                    Text("Vehicle Details")
                } footer: {
                    Text("Make sure you're updating the correct report. You can take actions such as matching the license plate, vin, or details that would ensure you have the correct vehicle.")
                }
                
                Section {
                    if let vehicleImage {
                        HStack {
                            Spacer()
                            Image(uiImage: vehicleImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 125, height: 125)
                                .clipped()
                            Spacer()
                        }
                    }
                    Picker("Update Type", selection: $updateReportType) {
                        ForEach(ReportType.updateCases) { type in
                            Text(type.rawValue)
                                .tag(type)
                        }
                    }
                    Menu("Vehicle Image") {
                        ForEach(ImagePickerSource.allCases) { source in
                            Button(source.rawValue) {
                                self.photoPickerSourceType = source.sourceType
                            }
                        }
                    }
                } header: {
                    Text("Update Details")
                }
                
                Section {
                    Button("Add Description") {
                        isShowingDescriptionView.toggle()
                    }
                } header: {
                    Text("Description")
                } footer: {
                    Text("Please describe your update")
                }
            }
            .navigationTitle("Update Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Update") {
                        prepareForUpload()
                    }
                }
            }
            .sheet(isPresented: $isShowingLocationSearchView) {
                NearbyLocationSearchView(location: $location)
            }
            .customSheetView(isPresented: $isShowingDescriptionView, detents: [.large()], showsIndicator: true) {
                ReportDescriptionView(description: $description)
            }
            .imagePicker(source: $photoPickerSourceType, image: $vehicleImage)
        }
        .disabled(isUploading)
    }
    
    private func getUsersLocation() -> Location? {
        guard let location = CLLocationManager.shared.usersCurrentLocation, self.location == nil else {
            return nil
        }
        
        return Location(coordinates: location)
    }
    
    @MainActor
    private func prepareForUpload() {
        isUploading = true
        Task {
            do {
                guard let uid = Auth.auth().currentUser?.uid else {
                    throw NewReportError.userIdError
                }
                
                guard let location = getUsersLocation() ?? location else {
                    throw NewReportError.locationError
                }
                
                var report = Report(uid: uid, type: updateReportType, Vehicle: self.originalReport.vehicle, details: self.description, location: location, discloseLocation: false)
                report.setAsUpdate(originalReport.role.associatedValue)
                try await reportsVM.addUpdateToOriginalReport(originalReport: originalReport, report: report, vehicleImage: vehicleImage)
                dismiss()
            } catch {
                print(error.localizedDescription)
                isUploading = false
            }
        }
    }
}
