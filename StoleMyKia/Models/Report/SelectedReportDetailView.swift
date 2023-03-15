//
//  SelectedReportDetailView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/14/23.
//

import SwiftUI

struct SelectedReportDetailView: View {
    
    @EnvironmentObject var reportsModel: ReportsViewModel
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        if let report = reportsModel.selectedReport {
            ZStack(alignment: .top) {
                ScrollView {
                    VStack(spacing: 2) {
                        Image("silvey")
                            .resizable()
                            .scaledToFill()
                            .frame(height: 300)
                            .clipped()
                            .edgesIgnoringSafeArea(.top)
                        HStack {
                            VStack {
                                VStack(alignment: .leading) {
                                    Text(report.reportType.rawValue)
                                        .font(.system(size: 25).weight(.heavy))
                                    HStack {
                                        Text("\(report.vehicleColor.rawValue) \(String(report.vehicleYear)) \(report.vehicleMake.rawValue) Elantra")
                                            .font(.system(size: 15))
                                            .foregroundColor(.gray)
                                    }
                                    Divider()
                                    Spacer()
                                    Text("\(report.description)")
                                        .multilineTextAlignment(.leading)
                                        .font(.system(size: 17))
                                }
                            }
                            Spacer()
                        }
                        .padding()
                        Spacer()
                    }
                }
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .floatingButtonStyle()
                    }
                    Spacer()
                    Menu {
                        Button {
                            
                        } label: {
                            Label("Bookmark", systemImage: "bookmark")
                        }
                        Button {
                            URL.getDirectionsToLocation(coords: report.coordinates)
                        } label: {
                            Label("Get Directions", systemImage: "map")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .floatingButtonStyle()
                    }
                }
                .padding()
            }
        }
    }
}


struct SelectedReportDetailView_Previews: PreviewProvider {
    
    @StateObject private static var reportsModel = ReportsViewModel()
    
    static var previews: some View {
        SelectedReportDetailView()
            .environmentObject(reportsModel)
    }
}
