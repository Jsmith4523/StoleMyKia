//
//  SelectedReportDetailView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/14/23.
//

import SwiftUI

struct SelectedReportDetailView: View {
    
    @EnvironmentObject var reportsModel: ReportsViewModel
    
    @State private var report: Report = .init(title: "Stolen", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.", reportType: .found, vehicleMake: .hyundai, vehicleColor: .gold, vehicleYear: 2017, vehicleDescription: "Elantra", lat: 40.90220, lon: -79.02322)
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 2) {
                    Image("silvey")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 300)
                        .clipped()
                    HStack {
                        VStack(alignment: .leading) {
                            Text(report.reportType.rawValue)
                                .font(.title.bold())
                            HStack {
                                
                                Text("\(String(report.vehicleYear)) \(report.vehicleMake.rawValue) Elantra")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Divider()
                            Spacer()
                            Text("\(report.description)")
                                .multilineTextAlignment(.leading)
                                .font(.system(size: 17))
                        }
                        Spacer()
                    }
                    .padding()
                    Spacer()
                }
            }
            HStack {
                Spacer()
                VStack {
                    closeButton()
                    Spacer()
                }
            }
            .padding()
        }
    }
    
    func closeButton() -> some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .resizable()
                .scaledToFit()
                .bold()
                .frame(width: 15, height: 15)
                .padding()
                .foregroundColor(.black)
                .background(Color(uiColor: .secondarySystemBackground))
                .clipShape(Circle())
                .shadow(radius: 4)
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
