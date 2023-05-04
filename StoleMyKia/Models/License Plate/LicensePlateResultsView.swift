//
//  LicensePlateResultsView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 5/3/23.
//

import SwiftUI

struct LicensePlateResultsView: View {
    
    @ObservedObject var licenseModel: LicenseScannerCoordinator
    
    let imageCache = ImageCache()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    ForEach(licenseModel.reports) { report in
                        LicensePlateResultCellView(report: report, imageCache: imageCache)
                        Divider()
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .tint(.brand)
            .navigationTitle("Results")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

fileprivate struct LicensePlateResultCellView: View {
    
    @State private var vehicleImage: UIImage?
    
    let report: Report
    let imageCache: ImageCache
    
    var body: some View {
        VStack {
            HStack {
                Text(report.postDate)
                Spacer()
            }
            .font(.system(size: 14))
            .foregroundColor(.gray)
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        Text(report.reportType.rawValue)
                            .font(.system(size: 25).weight(.heavy))
                        Text(report.vehicleDetails)
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
                Image(uiImage: vehicleImage ?? .vehiclePlaceholder)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 85, height: 85)
                    .cornerRadius(20)
            }
        }
        .padding()
        .onAppear {
            getVehicleImage()
        }
    }
    
    private func getVehicleImage() {
        if let imgUrl = report.imageURL {
            imageCache.getImage(imgUrl) { image in
                guard let image else {
                    return
                }
                withAnimation {
                    self.vehicleImage = image
                }
            }
        }
    }
}

struct LicensePlateResultsView_Previews: PreviewProvider {
    static var previews: some View {
        LicensePlateResultCellView(report: .init(dt: Date.now.epoch, reportType: .stolen, vehicleYear: 2017, vehicleMake: .hyundai, vehicleColor: .blue, vehicleModel: .elantra, licensePlate: nil, vin: nil, distinguishable: "", imageURL: "https://bloximages.newyork1.vip.townnews.com/richmond.com/content/tncms/assets/v3/classifieds/4/f3/4f3f34e1-4e56-523f-9619-a4b3d5efc26f/5ca3b8b932072.image.jpg", location: .init(address: nil, name: nil, lat: nil, lon: nil)), imageCache: ImageCache())
    }
}
