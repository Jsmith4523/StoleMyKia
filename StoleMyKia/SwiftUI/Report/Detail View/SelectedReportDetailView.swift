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
    
    @State private var isBookmarked: Bool = false
    @State private var updateQuantity: Int?
    
    @State private var isDeleting = false
    
    @State private var loadStatus: ReportLoadStatus = .loading
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
    
    let report: Report
    var timelineMapViewMode: TimelineMapViewMode = .presentWhenSelected
    
    var deleteCompletion: (() -> Void)? = nil
        
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
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
            .refreshable {
                await checkIfReportIsAvaliable(checkForMoreInfo: true)
            }
            .onAppear {
                Task {
                    await checkIfReportIsAvaliable(checkForMoreInfo: false)
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
                        if (report.hasVehicleImage || !(report.discloseLocation)) {
                            ZStack {
                                if report.hasVehicleImage {
                                    vehicleImageView
                                } else {
                                    if !(report.discloseLocation) {
                                        SelectedReportDetailMapView(report: report)
                                    }
                                }
                            }
                            .frame(width: UIScreen.main.bounds.width, height: 300)
                            .clipped()
                        }
                        VStack(spacing: 30) {
                            VStack(alignment: .leading) {
                                HStack {
                                    reportTypeLabelStyle(report: report)
                                    Spacer()
                                }
                                VStack(alignment: .leading, spacing: 10) {
                                    VStack(alignment: .leading, spacing: 7) {
                                        Text(report.vehicleDetails)
                                            .font(.system(size: 25).weight(.heavy))
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
                                        VStack(alignment: .leading) {
                                            if report.hasLicensePlate {
                                                Text(report.vehicle.licensePlateString)
                                            }
                                        }
                                        .font(.system(size: 17))
                                    }
                                    Text(report.distinguishableDetails)
                                        .font(.system(size: 16))
                                        .lineSpacing(2)
                                }
                            }
                        }
                        .padding()
                    }
                }
                Spacer()
                    .frame(height: 100)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !(isDeleting) {
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
            if !(report.isFalseReport || report.discloseLocation) {
                Button("Directions") {
                    URL.getDirectionsToLocation(title: report.appleMapsAnnotationTitle,
                                                coords: report.location.coordinates)
                }
            }
            if let currentUser = Auth.auth().currentUser {
                if report.uid == currentUser.uid {
                    Button("Delete", role: .destructive) {
                        presentDeleteAlert.toggle()
                    }
                } else {
                    Button("False Report") {
                        self.isShowingFalseReportView.toggle()
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingTimelineMapView) {
            TimelineMapView(detailMode: .report(self.report))
                .environmentObject(reportsVM)
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
        .interactiveDismissDisabled(isDeleting)
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
                    if !(report.isFalseReport) {
                        Button {
                            isShowingUpdateReportView.toggle()
                        } label: {
                            Label("Update Report", systemImage: "arrow.2.squarepath")
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
    
    private var vehicleImageView: some View {
        TabView {
            Image(uiImage: vehicleImage ?? .vehiclePlaceholder)
                .resizable()
                .scaledToFill()
                .redacted(reason: vehicleImage == nil ? .placeholder : [])
                .onAppear {
                    if (vehicleImage == nil) {
                        getVehicleImage()
                    }
                }
                .onTapGesture {
                    isShowingVehicleImageView.toggle()
                }
            if !(report.discloseLocation) {
                SelectedReportDetailMapView(report: report)
                    .onTapGesture {
                        presentTimelineMapView()
                    }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
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
            isDeleting = true
            do {
                try await reportsVM.deleteReport(report: report)
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                deleteCompletion?()
                dismiss()
            } catch {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                self.presentFailedDeletingReportAlert = true
                self.isDeleting = false
            }
        }
    }
    
    private func checkIfBookmarked() async {
        self.isBookmarked = await FirebaseUserManager.userHasBookmarkedReport(report.id)
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
    
    private func checkIfReportIsAvaliable(checkForMoreInfo: Bool = true) async {
        guard let doesExist = try? await ReportManager.manager.reportDoesExist(report.id), doesExist else {
            self.loadStatus = .error
            return
        }
        
        if checkForMoreInfo {
            await getUpdateQuantity()
            await checkIfBookmarked()
        }
        
        self.loadStatus = .loaded
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
        SelectedReportDetailView(report: [Report].testReports().first!)
            .environmentObject(ReportsViewModel())
            .environmentObject(UserViewModel())
    }
}
