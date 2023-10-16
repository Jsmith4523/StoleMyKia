//
//  TimelineListVIew.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/13/23.
//

import SwiftUI
import UIKit

struct TimelineListView: View {
    
    @Binding var shouldDismiss: Bool
    
    @EnvironmentObject var timelineMapVM: TimelineMapViewModel
    
    let reports: [Report]
        
    var body: some View {
        LazyVStack {
            ForEach(reports) { report in
                TimelineListCellView(report: report)
                    .onTapGesture {
                        shouldDismiss = true
                        timelineMapVM.selectAnnotation(report)
                    }
                Divider()
            }
        }
    }
}

fileprivate struct TimelineListCellView: View {
    
    @State private var vehicleImage: UIImage?
    
    let report: Report
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                VStack(alignment: .leading) {
                    HStack(spacing: 0) {
                        reportTypeLabelStyle(report: report)
                        if report.discloseLocation {
                            Image(systemName: "mappin.slash.circle")
                                .font(.system(size: 18).weight(.heavy))
                                .padding(4)
                                .background(Color.blue)
                                .cornerRadius(10)
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                        }
                    }
                    Text(report.distinguishableDetails)
                        .font(.system(size: 14))
                        .lineLimit(3)
                }
                Text(report.timeSinceString())
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            Spacer()
            if report.hasVehicleImage {
                vehicleImageView
                    .onAppear {
                        getVehicleImage()
                    }
            }
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
    }
    
    var vehicleImageView: some View {
        Image(uiImage: vehicleImage ?? .vehiclePlaceholder)
            .resizable()
            .scaledToFill()
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .redacted(reason: vehicleImage.isNil() ? .placeholder : [])
    }
    
    private func getVehicleImage() {
        ImageCache.shared.getImage(report.imageURL) { image in
            DispatchQueue.main.async {
                self.vehicleImage = image
            }
        }
    }
}

//#Preview {
//    NavigationView {
//        ScrollView {
//            TimelineListCellView(report: [Report].testReports().first!)
//                .preferredColorScheme(.dark)
//        }
//    }
//}
