//
//  LicensePlateResultsView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 5/3/23.
//

import SwiftUI

struct LicensePlateResultsView: View {
    
    @ObservedObject var licenseModel: LicenseScannerCoordinator
    
    let imageCache: ImageCache
    
    var body: some View {
        VStack {
            TabView {
                ForEach(licenseModel.reports) { report in
                    
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
        }
    }
}

fileprivate struct LicensePlateResultCellView: View {
    
    @State private var vehicleImage: UIImage?
    
    let report: Report
    let imageCache: ImageCache
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(report.reportType.rawValue)
                    .font(.system(size: 25).weight(.heavy))
                Text(report.vehicleDetails)
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
            }
            .multilineTextAlignment(.leading)
            Spacer()
            if let vehicleImage {
                Image(uiImage: vehicleImage)
            }
        }
        .frame(height: 200)
        .padding()
        .background(.ultraThickMaterial)
        .cornerRadius(35)
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
            }
        }
    }
}

struct LicensePlateResultsView_Previews: PreviewProvider {
    static var previews: some View {
        LicensePlateResultCellView(report: .init(dt: Date.now.epoch, reportType: .stolen, vehicleYear: 2017, vehicleMake: .hyundai, vehicleColor: .blue, vehicleModel: .elantra, licensePlate: nil, vin: nil, imageURL: "https://firebasestorage.googleapis.com/v0/b/stolemykia.appspot.com/o/83FE52C0-3A19-461F-BD61-AF4B97E4C5C8?alt=media&token=dd877c73-2f55-4062-8251-f920012173d8", location: .init(address: nil, name: nil, lat: nil, lon: nil)), imageCache: ImageCache())
    }
}
