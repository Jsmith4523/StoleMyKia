//
//  SelectedReportDetailView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/14/23.
//

import SwiftUI

struct SelectedReportDetailView: View {
    
    @State private var isDeleting = false
    
    @State private var alertErrorRemovingPost = false
    @State private var alertOfRemovingPosting = false
    
    @State private var vehicleImage: UIImage?
    
    let report: Report
    
    var completion: (() -> Void)?
    
    @EnvironmentObject var reportsModel: ReportsViewModel
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                ZStack {
                    ReportMapView(report: report)
                }
                .frame(height: 200)
                .cornerRadius(15)
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(report.type)
                            .font(.system(size: 35).weight(.heavy))
                        VStack(alignment: .leading, spacing: 6) {
                            Label {
                                Text(report.vehicleDetails)
                            } icon: {
                                Image(systemName: "car")
                            }

                            if let location = report.location, let name = location.name, !(name.isEmpty) {
                                Label {
                                    Text(name)
                                } icon: {
                                    Image(systemName: "mappin.and.ellipse")
                                }
                            }
                        }
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                    }
                    Spacer()
                }
                Spacer()
                    .frame(height: 15)
                VStack {
                    Text(report.details)
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 18.5))
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding(.horizontal)
            .onAppear {
                getVehicleImage(report.imageURL)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if report.uid == reportsModel.firebaseUserDelegate?.uid {
                        Button {
                            self.alertOfRemovingPosting.toggle()
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }
            }
            .disabled(isDeleting)
            .alert("Remove Report", isPresented: $alertOfRemovingPosting) {
                Button("Remove", role: .destructive) {
                    removePost(report: report)
                }
            } message: {
                Text("Are you sure you want to remove this post?")
            }
            .alert("Unable to remove post", isPresented: $alertErrorRemovingPost) {
                Button("OK") {}
            } message: {
                Text("There was an error removing this report. Please try again later.")
            }
            .onDisappear {
                reportsModel.reportDetailMode = nil
            }
        }
    }
    
    private func getVehicleImage(_ urlString: String?) {
        ImageCache.shared.getImage(urlString) { image in
            withAnimation {
                self.vehicleImage = image
            }
        }
    }
    
    private func removePost(report: Report) {
        isDeleting = true
        reportsModel.deleteReport(report) { status in
            guard status else {
                isDeleting = false
                alertErrorRemovingPost.toggle()
                return
            }
            dismiss()
            
            if let completion = completion {
                completion()
            }
            
            isDeleting = false
        }
    }
}

fileprivate struct ReportMapView: View {
    
    let report: Report
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ReportDetailViewMap(selectAnnotation: true, report: report)
        }
    }
}

private extension Image {
    
    func reportButtons() -> some View {
        return self
            .resizable()
            .scaledToFit()
            .frame(width: 20, height: 20)
            .padding(10)
            .foregroundColor(.white)
            .background(Color.accentColor)
            .clipShape(Circle())
    }
}
