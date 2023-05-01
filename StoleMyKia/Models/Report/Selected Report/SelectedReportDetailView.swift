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
    
    let report: Report?
    
    let imageCache: ImageCache
        
    @EnvironmentObject var reportsModel: ReportsViewModel
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            if let report {
                VStack(alignment: .leading) {
                    ZStack {
                        if !(report.imageURL == nil) {
                            if let vehicleImage {
                                Image(uiImage: vehicleImage)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                Image.vehiclePlaceholder
                                    .resizable()
                                    .scaledToFill()
                            }
                        } else {
                            ReportMapView(report: report)
                        }
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
                                //                                Label {
                                //                                    //Text(vin.vinFormat() ?? "Not avaliable")
                                //                                } icon: {
                                //                                    Image(systemName: "123.rectangle")
                                //                                }
                                
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
            }
        }
    }
    
    private func getVehicleImage(_ urlString: String?) {
        imageCache.getImage(urlString) { image in
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
            isDeleting = false
        }
    }
}

fileprivate struct ReportMapView: View {
    
    let report: Report
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ReportMap(selectAnnotation: true, report: report)
//            Button {
//
//            } label: {
//                Label("Get Directions", systemImage: "arrow.triangle.turn.up.right.circle")
//                    .padding(10)
//                    .font(.system(size: 14).weight(.semibold))
//                    .background(Color.accentColor)
//                    .cornerRadius(2)
//                    .foregroundColor(.white)
//            }
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


struct SelectedReportDetailView_Previews: PreviewProvider {
    
    @StateObject private static var reportsModel = ReportsViewModel()
    
    static var previews: some View {
        SelectedReportDetailView(report: .init(dt: Date.now.epoch, reportType: .stolen, vehicleYear: 2015, vehicleMake: .hyundai, vehicleColor: .red, vehicleModel: .elantra, licensePlate: nil, vin: nil, location: .init(address: nil, name: "Apple Carnige", lat: nil, lon: nil)), imageCache: ImageCache())
            .environmentObject(reportsModel)
    }
}
