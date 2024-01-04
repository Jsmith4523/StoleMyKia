//
//  ReportComposeVehicleModelView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 1/4/24.
//

import SwiftUI

struct ReportComposeVehicleModelView: View {
    
    @EnvironmentObject var composeVM: ReportComposeViewModel
    
    var body: some View {
        Form {
            ForEach(VehicleModel.allCases.manufacturer(composeVM.vehicleMake)) { model in
                vehicleModelCellView(model)
                    .onTapGesture {
                        composeVM.vehicleModel = model
                    }
            }
        }
        .navigationTitle("Vehicle Model")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink("Next") {
                    ReportComposeVehicleYearView()
                        .environmentObject(composeVM)
                }
            }
        }
    }
    
    @ViewBuilder
    private func vehicleModelCellView(_ model: VehicleModel) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(model.rawValue)
                    .font(.system(size: 19).bold())
                Text(model.yearRangeLabel)
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
            }
            Spacer()
            if composeVM.vehicleModel == model {
                Image.greenCheckMark
            }
        }
        .padding(10)
    }
}

#Preview {
    NavigationStack {
        ReportComposeVehicleModelView()
            .environmentObject(ReportComposeViewModel())
    }
}
