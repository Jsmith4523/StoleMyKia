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
    
    @Binding var isPresented: Bool
    
    let originalReport: Report
    
    @State private var isShowingBeSafeView = false
    @State private var isShowingWarningView = false
    @State private var isUploading = false
    @State private var isShowingDescriptionView = false
    @State private var isShowingLocationSearchView = false
    
    @State private var discloseLocation = false
    @State private var allowsForContact = false
    
    @State private var alertPresentLocationServicesDenied = false
    @State private var presentError = false
    
    @State private var vehicleImage: UIImage?
    @State private var description: String = ""
    @Binding var updateReportType: ReportType
    
    @State private var photoPickerSourceType: UIImagePickerController.SourceType?
    
    @State private var location: Location?
    
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var reportsVM: ReportsViewModel
        
    var isSatisfied: Bool {
        !(self.description.count >= Int.descriptionMinCharacterCount && self.description.count <= Int.descriptionMaxCharacterCount + 1)
    }
        
    var body: some View {
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
                        Text(originalReport.vehicle.hiddenVinString)
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
                LabeledContent("Update Type") {
                    Text(updateReportType.rawValue)
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
                    .tint(.blue)
                Toggle("Contact Me", isOn: $allowsForContact)
                    .tint(.blue)
            } header: {
                Text("Options")
            } footer: {
                Text("Contacting is automatically disabled when the initial report is marked resolved or deleted. You can manually disable contacting within the detail screen of your update.")
            }
        }
        .navigationTitle("Update Report")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    isShowingBeSafeView.toggle()
                } label: {
                    Image(systemName: "checkerboard.shield")
                        .foregroundColor(.green)
                }
                if isUploading {
                    ProgressView()
                } else {
                    Button("Update") {
                        prepareForUpload()
                    }
                    .disabled(isSatisfied)
                }
            }
        }
        .alert("Unable to update report", isPresented: $presentError) {
            Button("OK") {}
        } message: {
            Text("The initial report cannot receive updates at the moment")
        }
        .alert("Unable to retrieve current location", isPresented: $alertPresentLocationServicesDenied) {
            Button("Location Settings") { URL.openApplicationSettings() }
            Button("OK") {}
        } message: {
            Text("Please check your location services settings and/or network connectivity and try again.")
        }
        .sheet(isPresented: $isShowingLocationSearchView) {
            NearbyLocationSearchView(location: $location)
        }
        .sheet(isPresented: $isShowingWarningView) {
            ReportComposeReminderView(postCompletion: prepareForUpload)
        }
        .customSheetView(isPresented: $isShowingDescriptionView, detents: [.large()], showsIndicator: true) {
            ReportComposeDescriptionView(description: $description)
        }
        .fullScreenCover(item: $photoPickerSourceType) { source in
            PhotoPicker(selectedImage: $vehicleImage, source: source)
        }
        .fullScreenCover(isPresented: $isShowingBeSafeView) {
            SafetyView()
        }
        .disabled(isUploading)
        .navigationBarBackButtonHidden(isUploading)
        .interactiveDismissDisabled(self.isUploading)
    }
    
    private func prepareForUpload() {
        isUploading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.60) {
            Task {
                do {
                    guard let uid = Auth.auth().currentUser?.uid else {
                        throw NewReportError.userIdError
                    }
                    
                    guard let userLocation = CLLocationManager.shared.usersCurrentLocation else {
                        self.alertPresentLocationServicesDenied.toggle()
                        self.isUploading = false
                        return
                    }
                    
                    var location: Location
                    
                    if discloseLocation {
                        location = Location.disclose(lat: userLocation.latitude, long: userLocation.longitude)
                    } else {
                        location = Location(coordinate: userLocation)
                    }
                    
                    var report = Report(uid: uid, type: updateReportType, Vehicle: self.originalReport.vehicle, details: self.description, location: location, discloseLocation: self.discloseLocation)
                    report.allowsForContact = allowsForContact
                    report.setAsUpdate(originalReport.role.associatedValue)
                    try await reportsVM.addUpdateToOriginalReport(originalReport: originalReport, report: report, vehicleImage: vehicleImage)
                    self.isPresented = false
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                } catch {
                    isUploading = false
                    self.presentError.toggle()
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                }
            }
        }
    }
}


#Preview {
    UpdateReportView(isPresented: .constant(false), originalReport: [Report].testReports().first!, updateReportType: .constant(.stolen))
}
