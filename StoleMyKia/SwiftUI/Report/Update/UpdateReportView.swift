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
    
    @State private var discloseLocation = false
    
    @State private var alertPresentLocationServicesDenied = false
    @State private var presentError = false
    
    @State private var vehicleImage: UIImage?
    @State private var description: String = ""
    @State private var updateReportType: ReportType = .found
    
    @State private var photoPickerSourceType: UIImagePickerController.SourceType?
    
    @State private var location: Location?
    
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var reportsVM: ReportsViewModel
    
    @Environment (\.dismiss) var dismiss
    
    var isSatisfied: Bool {
        !(self.description.count >= Int.descriptionMinCharacterCount && self.description.count <= Int.descriptionMaxCharacterCount + 1)
    }
        
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
                            Text("\(ApplicationFormats.vinFormat(originalReport.vehicle.vinString) ?? "")")
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
                    Text("Describe your situation with the \(originalReport.vehicleDetails)")
                }
                
                Section {
                    Toggle("Hide Location", isOn: $discloseLocation)
                } header: {
                    Text("Options")
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
                    .disabled(isSatisfied)
                }
            }
            .alert("Unable to update report", isPresented: $presentError) {
                Button("OK") {}
            } message: {
                Text("The initial report is either no longer available, deleted, or had an issue receiving updates.")
            }
            .alert("Unable to retrieve your current location", isPresented: $alertPresentLocationServicesDenied) {
                Button("OK") {}
            } message: {
                Text("Please check your location services settings and/or network connectivity and try again.")
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
        .interactiveDismissDisabled()
    }
    
    @MainActor
    private func prepareForUpload() {
        isUploading = true
        Task {
            do {
                guard let uid = Auth.auth().currentUser?.uid else {
                    throw NewReportError.userIdError
                }
                
                guard let userLocation = CLLocationManager.shared.usersCurrentLocation else {
                    self.alertPresentLocationServicesDenied.toggle()
                    return
                }
                
                var location: Location
                
                if discloseLocation {
                    location = Location.disclose(lat: userLocation.latitude, long: userLocation.longitude)
                } else {
                    location = Location(coordinate: userLocation)
                }
                
                var report = Report(uid: uid, type: updateReportType, Vehicle: self.originalReport.vehicle, details: self.description, location: location, discloseLocation: self.discloseLocation, allowsForUpdates: true)
                report.setAsUpdate(originalReport.role.associatedValue)
                try await reportsVM.addUpdateToOriginalReport(originalReport: originalReport, report: report, vehicleImage: vehicleImage)
                dismiss()
            } catch {
                isUploading = false
                self.presentError.toggle()
            }
        }
    }
}

//
//#Preview {
//    UpdateReportView(originalReport: [Report].testReports().first!)
//}
