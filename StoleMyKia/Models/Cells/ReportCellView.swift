//
//  ReportCellView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 5/28/23.
//

import Foundation
import SwiftUI

struct ReportCellView: View {
    
    @State private var vehicleImage: UIImage?
    
    @State private var alertDeleteReport = false
    @State private var alertGenericError = false
    
    @State private var isLoadingBookmark = false
    
    let report: Report
    
    @EnvironmentObject var userModel: UserViewModel
    @EnvironmentObject var reportsModel: ReportsViewModel
    
    ///Completion if this report is delete through the cell
    var deleteCompletionHandler: (() -> Void)?
        
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    HStack {
                        Text(report.type)
                            .font(.system(size: 20).weight(.heavy))
                        Spacer()
                    }
                    VStack(alignment: .leading, spacing: 5) {
                        Text(report.vehicleDetails)
                            .font(.system(size: 17))
                            .bold()
                        if let licensePlate = report.licensePlateString {
                            Label(licensePlate, systemImage: "character.textbox")
                                .font(.system(size: 17))
                                .foregroundColor(.black)
                        }
                        HStack {
                            Text(report.postDate)
                            Divider()
                                .frame(height: 15)
                            Text(report.postTime)
                        }
                        .font(.system(size: 15.5))
                    }
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                }
                Spacer()
                if report.hasVehicleImage {
                    Image(uiImage: vehicleImage ?? .vehiclePlaceholder)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .cornerRadius(10)
                }
            }
            HStack(spacing: 15) {
                if !isLoadingBookmark {
                    Image(systemName: isBookmarked() ? "bookmark.fill" : "bookmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .foregroundColor(isBookmarked() ? .brand : .gray)
                        .onTapGesture {
                            checkBookmark()
                        }
                } else {
                    ProgressView()
                        .frame(width: 25, height: 25)
                }
                if isCurrentUsersReport() {
                    Image(systemName: "trash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.gray)
                        .onTapGesture {
                            alertDeleteReport.toggle()
                        }
                }
            }
        }
        .padding()
        .onAppear {
            getVehicleImage()
        }
        .alert("There was an error with that request", isPresented: $alertGenericError) {
            Button("OK") {}
        } message: {
            Text("We were unable to complete that request at the moment. Please try again later.")
        }
        .alert("Delete report", isPresented: $alertDeleteReport) {
            Button("Delete", role: .destructive) { deleteReport() }
        } message: {
            Text("Once deleted, this action cannot be undo")
        }
    }
    
    private func getVehicleImage() {
        ImageCache.shared.getImage(report.imageURL) { image in
            withAnimation {
                self.vehicleImage = image
            }
        }
    }
    
    //Checks if the report has been bookmarked by the logged in user
    private func isBookmarked() -> Bool {
        userModel.containsBookmarkReport(id: self.report.id)
    }
    
    private func isCurrentUsersReport() -> Bool {
        guard let currentUser = userModel.currentUser(), let reportUid = report.uid, currentUser.uid == reportUid else {
            return false
        }
        
        return true
    }
    
    private func deleteReport() {
        reportsModel.deleteReport(report) { success in
            guard success else {
                alertGenericError.toggle()
                return
            }
            
            guard let deleteCompletionHandler else {
                return
            }
            
            deleteCompletionHandler()
        }
    }
    
    private func saveBookmark() {
        userModel.bookmarkReport(id: report.id) { success in
            guard success else {
                alertGenericError.toggle()
                self.isLoadingBookmark = false
                return
            }
            self.isLoadingBookmark = false
        }
    }
    
    private func removeBookmark() {
        userModel.removeBookmark(id: report.id) { success in
            guard success else {
                self.alertGenericError.toggle()
                self.isLoadingBookmark = false
                return
            }
            self.isLoadingBookmark = false
        }
    }
    
    private func checkBookmark() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        isLoadingBookmark = true
        
        switch isBookmarked() {
        case true:
            removeBookmark()
        case false:
            saveBookmark()
        }
    }
}


struct MyPreviewProvider23_Previews: PreviewProvider {
    static var previews: some View {
        ReportCellView(report: .init(dt: Date.now.epoch, reportType: .carjacked, vehicle: .init(vehicleYear: 2017, vehicleMake: .hyundai, vehicleColor: .gray, vehicleModel: .elantra), distinguishable: "", location: .init(address: nil, name: nil, lat: 0, lon: 0)))
            .environmentObject(UserViewModel())
    }
}
