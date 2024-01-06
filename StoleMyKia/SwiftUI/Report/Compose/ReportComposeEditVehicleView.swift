//
//  ReportComposeEditVehicleView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 1/6/24.
//

import SwiftUI

struct ReportComposeEditVehicleView: View {
    
    @EnvironmentObject var composeVM: ReportComposeViewModel
    
    var body: some View {
        Form {
            Section("Report Type") {
                NavigationLink {
                    ReportComposeReportTypeView(isPresented: .constant(false), canPushToNextView: false)
                } label: {
                    itemCellView(title: "Report Type", subtitle: composeVM.reportType.rawValue)
                }
            }
            Section("Vehicle Details") {
                NavigationLink {
                    ReportComposeVehicleColorView(canPushToNextView: false)
                        .environmentObject(composeVM)
                } label: {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Color")
                            .font(.system(size: 22).weight(.heavy))
                        HStack {
                            Circle()
                                .fill(composeVM.vehicleColor.color)
                                .frame(width: 20, height: 20)
                            Text(composeVM.vehicleColor.rawValue)
                                .font(.system(size: 17))
                        }
                    }
                    .padding()
                }
                NavigationLink {
                    ReportComposeVehicleMakeView(canPushToNextView: false)
                        .environmentObject(composeVM)
                } label: {
                    itemCellView(title: "Manufacturer", subtitle: composeVM.vehicleMake.rawValue)
                }
                NavigationLink {
                    ReportComposeVehicleModelView(canPushToNextView: false)
                        .environmentObject(composeVM)
                } label: {
                    itemCellView(title: "Model", subtitle: composeVM.vehicleModel.rawValue)
                }
                NavigationLink {
                    ReportComposeVehicleYearView(canPushToNextView: false)
                        .environmentObject(composeVM)
                } label: {
                    itemCellView(title: "Year", subtitle: "\(composeVM.vehicleYear)")
                }
            }
        }
        .environmentObject(composeVM)
        .interactiveDismissDisabled()
        .navigationTitle("Edit")
    }
    
    @ViewBuilder
    private func itemCellView(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 22).weight(.heavy))
            HStack {
                Text(subtitle)
                    .font(.system(size: 17))
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        ReportComposeEditVehicleView()
            .environmentObject(ReportComposeViewModel())
    }
}
