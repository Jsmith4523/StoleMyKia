//
//  ReportComposeVehicleMakeView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 1/4/24.
//

import SwiftUI

struct ReportComposeVehicleMakeView: View {
    
    @EnvironmentObject var composeVM: ReportComposeViewModel
    
    var canPushToNextView = true
    
    var body: some View {
        Form {
            ForEach(VehicleMake.allCases) { manufacturer in
                manufacturerCellView(manufacturer)
                    .onTapGesture {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        composeVM.vehicleMake = manufacturer
                    }
            }
        }
        .navigationTitle("Manufacturer")
        .toolbar {
            if canPushToNextView {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink("Next") {
                        ReportComposeVehicleModelView()
                            .environmentObject(composeVM)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func manufacturerCellView(_ manufacturer: VehicleMake) -> some View {
        HStack {
            Text(manufacturer.rawValue)
                .font(.system(size: 20))
            Spacer()
            if composeVM.vehicleMake == manufacturer {
                Image.greenCheckMark
            }
        }
        .padding(10)
    }
}

#Preview {
    NavigationStack {
        ReportComposeVehicleMakeView()
            .environmentObject(ReportComposeViewModel())
    }
}
