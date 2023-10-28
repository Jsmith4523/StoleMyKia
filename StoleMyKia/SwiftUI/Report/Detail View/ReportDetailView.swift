//
//  SelectedReportDetailView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/10/23.
//

import SwiftUI
import FirebaseAuth
import MapKit

struct SelectedReportDetailView: View {
    
    private enum ReportLoadStatus {
        case loading, loaded, error
    }
    
    ///Determines how the TimelineMapView will present itself when selected by the user
    enum TimelineMapViewMode {
        case dismissWhenSelected
        case presentWhenSelected
    }
    
    @State private var report: Report!
    
    @State private var isBookmarked: Bool = false
    @State private var updateQuantity: Int?
    
    @State private var isLoading = false
    
    @State private var loadStatus: ReportLoadStatus = .loading
    
    @State private var presentDisableUpdatesAlert = false
    @State private var presentResolveReportsAlert = false
    @State private var presentGenericErrorAlert = false
    @State private var presentDeleteAlert = false
    @State private var presentFailedDeletingReportAlert = false
    
    @State private var isShowingVehicleImageView = false
    
    @State private var isShowingFalseReportView = false
    @State private var isShowingTimelineMapView = false
    @State private var isShowingUpdateReportView = false
    @State private var isShowingReportOptions = false
    
    @State private var vehicleImage: UIImage?
    
    @EnvironmentObject var reportsVM: ReportsViewModel
    @EnvironmentObject var userVM: UserViewModel
    
    @Environment (\.dismiss) var dismiss
    
    let reportId: UUID
    var timelineMapViewMode: TimelineMapViewMode = .presentWhenSelected
    
    var deleteCompletion: (() -> Void)? = nil
        
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                if let report {
                    NavigationLink("", isActive: $isShowingTimelineMapView) {
                        TimelineMapView(reportAssociatedId: report.role.associatedValue)
                            .environmentObject(reportsVM)
                    }
                }
                ScrollView {
                    ZStack {
                        switch loadStatus {
                        case .loading:
                            ReportSkeletonView()
                        case .loaded:
                            detailView
                        case .error:
                            errorView
                        }
                    }
                }
                buttonsView
            }
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await fetchReportDetails(checkForMoreInfo: true)
            }
            .onAppear {
                Task {
                    if (report == nil) {
                        await fetchReportDetails(checkForMoreInfo: false)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(Color(uiColor: .label))
                    }
                }
            }
        }
    }
    
    private var errorView: some View {
        VStack {
            Spacer()
                .frame(height: 120)
            VStack {
                VStack(spacing: 30) {
                    Image(systemName: "archivebox")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                    Text("Sorry, this report is not available at the moment. Please try again later.")
                        .font(.system(size: 18))
                }
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                Spacer()
                    .frame(height: 150)

            }
        }
        .padding()
    }
    
    private var detailView: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack {
                VStack(spacing: 20) {
                    VStack(alignment: .leading) {
                        TabView {
                            if report.hasVehicleImage {
                                Image(uiImage: vehicleImage ?? .vehiclePlaceholder)
                                    .resizable()
                                    .scaledToFill()
                                    .redacted(reason: vehicleImage.isNil() ? .placeholder : [])
                                    .onTapGesture {
                                        self.isShowingVehicleImageView.toggle()
                                    }
                                    .onAppear {
                                        getVehicleImage()
                                    }
                            }
                            SelectedReportDetailMapView(report: report)
                                .onTapGesture {
                                    presentTimelineMapView()
                                }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .always))
                        .frame(width: UIScreen.main.bounds.width, height: 300)
                        .clipped()
                        VStack {
                            VStack(spacing: 30) {
                                VStack(alignment: .leading) {
                                    HStack {
                                        ReportLabelView(report: report)
                                        Spacer()
                                    }
                                    VStack(alignment: .leading, spacing: 10) {
                                        VStack(alignment: .leading, spacing: 18) {
                                            VStack(alignment: .leading, spacing: 7) {
                                                Text(report.vehicleDetails)
                                                    .font(.system(size: 25).weight(.heavy))
                                                if report.hasLicensePlateOrVin {
                                                    HStack {
                                                        if report.hasLicensePlate {
                                                            Text(report.vehicle.licensePlateString)
                                                        }
                                                        if (report.hasLicensePlateAndVin) {
                                                            Divider()
                                                                .frame(height: 15)
                                                        }
                                                        if report.hasVin {
                                                            Text("VIN: \(report.vehicle.hiddenVinString)")
                                                        }
                                                    }
                                                    .font(.system(size: 18).bold())
                                                }
                                            }
                                            HStack {
                                                Text(report.timeSinceString())
                                                Divider()
                                                Label("\(updateQuantity ?? 0)", systemImage: "arrow.2.squarepath")
                                                Divider()
                                                Text(report.location.distanceFromUser)
                                            }
                                            .frame(height: 15)
                                            .font(.system(size: 16.5))
                                            .foregroundColor(.gray)
                                        }
                                        Text(report.distinguishableDetails)
                                            .font(.system(size: 18))
                                            .lineSpacing(2)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
                Spacer()
                    .frame(height: 100)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !(isLoading) {
                    Button {
                        isShowingReportOptions.toggle()
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                } else {
                    ProgressView()
                }
            }
        }
        .tint(Color(uiColor: .label))
        .confirmationDialog("Options", isPresented: $isShowingReportOptions) {
            Button(isBookmarked ? "Undo Bookmark" : "Bookmark") {
                setBookmark()
            }
            Button("Directions") {
                URL.getDirectionsToLocation(title: report.appleMapsAnnotationTitle,
                                            coords: report.location.coordinates)
            }
            if report.belongsToUser {
                if !(report.role.isAnUpdate) {
                    if (report.allowsForUpdates && !(report.hasBeenResolved)) {
                        Button("Disable Updates") {
                            presentDisableUpdatesAlert.toggle()
                        }
                    }
                    if !(report.hasBeenResolved) {
                        Button("Resolved!") {
                            presentResolveReportsAlert.toggle()
                        }
                    }
                }
                Button("Delete", role: .destructive) {
                    presentDeleteAlert.toggle()
                }
            } else {
                if (report.allowsForUpdates && !(report.hasBeenResolved && report.belongsToUser)) {
                    Button("Contact User") {
                        
                    }
                }
                Button("False Report") {
                    self.isShowingFalseReportView.toggle()
                }
            }
        }
        .fullScreenCover(isPresented: $isShowingFalseReportView) {
            FalseReportView(report: report)
                .environmentObject(userVM)
        }
        .sheet(isPresented: $isShowingUpdateReportView) {
            UpdateReportView(originalReport: report)
                .environmentObject(userVM)
                .environmentObject(reportsVM)
        }
        .fullScreenCover(isPresented: $isShowingVehicleImageView) {
            VehicleImageView(vehicleImage: $vehicleImage)
        }
        .alert("Delete Report?", isPresented: $presentDeleteAlert) {
            Button("Yes", role: .destructive) {
                beginDeletingReport()
            }
        } message: {
            Text(report.deletionBodyText)
        }
        .alert("Unable to delete", isPresented: $presentFailedDeletingReportAlert) {
            Button("OK") {}
        } message: {
            Text("Something went wrong trying to delete this report. Please try again!")
        }
        .alert("Resolve Report", isPresented: $presentResolveReportsAlert) {
            Button("Yes") { resolveReport() }
            Button("Never mind"){}
        } message: {
            Text("When resolving a report, it will no longer receive updates and users can no longer contact you (if enabled). Once resolved, it CANNOT be reversed. Do you wish to continue?")
        }
        .alert("Disable Updates", isPresented: $presentDisableUpdatesAlert) {
            Button("Yes", role: .destructive) { disableUpdates() }
        } message: {
            Text("When disabling updates, users can no longer update your report, but can still contact you (if enabled) Once disabled, it CANNOT be re-enabled. Do you wish to continue?")
        }
        .alert("There was an error completing that request", isPresented: $presentGenericErrorAlert) {
            Button("OK") {}
        } message: {
            Text("An error occurred attempting to process that request. Please try again.")
        }
        .task {
            if updateQuantity.isNil() {
                await getUpdateQuantity()
            }
        }
    }
    
    private var buttonsView: some View {
        VStack(spacing: 5) {
            if loadStatus == .loaded {
                Menu {
                    //As long as the report is not false, allows for updates, and has not been resolved, then it can be updated
                    if !(report.isFalseReport) {
                        if (report.allowsForUpdates && !report.hasBeenResolved) {
                            Button {
                                isShowingUpdateReportView.toggle()
                            } label: {
                                Label("Update Report", systemImage: "arrow.2.squarepath")
                            }
                        }
                    }
                    Button {
                        presentTimelineMapView()
                    } label: {
                        Label("View Timeline", systemImage: "map")
                    }
                } label: {
                    ZStack(alignment: .bottomTrailing) {
                        Image(systemName: "arrow.2.squarepath")
                            .font(.system(size: 18.5).bold())
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.brand)
                            .clipShape(Circle())
                    }
                    .padding()
                }
            }
        }
        .task {
            await checkIfBookmarked()
        }
    }
    
    private func presentTimelineMapView() {
        //Prevents allocating a new MKMapView in cases where the detail view
        //is presented within the TimelineMapView
        switch timelineMapViewMode {
        case .dismissWhenSelected:
            dismiss()
        case .presentWhenSelected:
            self.isShowingTimelineMapView.toggle()
        }
    }
    
    private func beginDeletingReport() {
        Task {
            isLoading = true
            do {
                try await reportsVM.deleteReport(report: report)
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                deleteCompletion?()
                dismiss()
            } catch {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                self.presentFailedDeletingReportAlert = true
                self.isLoading = false
            }
        }
    }
    
    private func checkIfBookmarked() async {
        self.isBookmarked = await FirebaseUserManager.userHasBookmarkedReport(reportId)
    }
    
    private func setBookmark() {
        Task {
            if isBookmarked {
                self.isBookmarked = false
                try! await FirebaseUserManager.undoBookmark(report.id)
            } else {
                do {
                    self.isBookmarked = true
                    try await FirebaseUserManager.bookmarkReport(report.id)
                } catch {
                    self.isBookmarked = false
                }
            }
        }
    }
    
    private func fetchReportDetails(checkForMoreInfo: Bool = true) async {
        self.loadStatus = .loading
        guard let report = try? await ReportManager.manager.fetchSingleReport(reportId) else {
            if !(report == nil) {
                self.loadStatus = .error
            } else {
                self.loadStatus = .loaded
            }
            return
        }
        
        self.report = nil
        self.report = report
        
        if checkForMoreInfo {
            await getUpdateQuantity()
            await checkIfBookmarked()
        }
        
        self.loadStatus = .loaded
    }
    
    private func disableUpdates() {
        isLoading = true
        self.loadStatus = .loading
        Task {
            do {
                try await ReportManager.manager.disableUpdates(reportId)
                await fetchReportDetails()
                isLoading = false
            } catch {
                isLoading = false
                presentGenericErrorAlert.toggle()
            }
        }
    }
    
    private func resolveReport() {
        isLoading = true
        self.loadStatus = .loading
        Task {
            do {
                try await ReportManager.manager.setAsResolved(reportId)
                await fetchReportDetails()
                isLoading = false
            } catch {
                isLoading = false
                if (report == nil) {
                    self.loadStatus = .error
                } else {
                    self.loadStatus = .loaded
                }
                presentGenericErrorAlert.toggle()
            }
        }
    }
    
    private func getVehicleImage() {
        ImageCache.shared.getImage(report.imageURL) { image in
            self.vehicleImage = image
        }
    }
    
    private func getUpdateQuantity() async {
        let quantity = await reportsVM.getNumberOfReportUpdates(report: report)
        self.updateQuantity = quantity
    }
}

struct SelectedReportDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SelectedReportDetailView(reportId: UUID.ID(uuidString: "1B5F8667-4638-4535-86C6-233D63CE5A5D")!)
            .environmentObject(ReportsViewModel())
            .environmentObject(UserViewModel())
    }
}
