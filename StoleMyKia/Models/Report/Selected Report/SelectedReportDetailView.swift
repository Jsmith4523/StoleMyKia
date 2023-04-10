//
//  SelectedReportDetailView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/14/23.
//

import SwiftUI

struct SelectedReportDetailView: View {
    
    @State private var vehicleImage: UIImage?
    
    let imageCache: ImageCache
    
    @EnvironmentObject var reportsModel: ReportsViewModel
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            if let report = reportsModel.selectedReport {
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
                        VStack(alignment: .leading) {
                            Text(report.type)
                                .font(.system(size: 35).weight(.heavy))
                            Text(report.vehicleDetails)
                                .font(.system(size: 18))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    HStack {
                        Button {
                            
                        } label: {
                            Image(systemName: "map")
                                .reportButtons()
                        }
                        Button {
                            
                        } label: {
                            Image(systemName: "eye")
                                .reportButtons()
                        }
                    }
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
                }
            }
        }
    }
    
    func getVehicleImage(_ urlString: String?) {
        imageCache.getImage(urlString) { image in
            withAnimation {
                self.vehicleImage = image
            }
        }
    }
}

fileprivate struct ReportMapView: View {
    
    let report: Report
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ReportMap(selectAnnotation: true, report: report)
            Button {
                
            } label: {
                Label("Get Directions", systemImage: "arrow.triangle.turn.up.right.circle")
                    .padding(10)
                    .font(.system(size: 14).weight(.semibold))
                    .background(Color.accentColor)
                    .cornerRadius(2)
                    .foregroundColor(.white)
            }
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
        SelectedReportDetailView(imageCache: ImageCache())
            .environmentObject(reportsModel)
    }
}
