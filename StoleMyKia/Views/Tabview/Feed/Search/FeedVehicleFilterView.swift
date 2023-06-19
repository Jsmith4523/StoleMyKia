//
//  FeedVehicleFilterView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/11/23.
//

import SwiftUI

struct FeedVehicleFilterView: View {
    
    @Binding var vehicleYear: Int?
    @Binding var vehicleMake: VehicleMake?
    @Binding var vehicleModel: VehicleModel?
    
    var body: some View {
        NavigationView {
            Form {
                Picker("Year", selection: $vehicleYear) {
                    ForEach(vehicleModel?.year ?? VehicleModel.affectedYearRange, id: \.self) {
                        Text(String($0))
                            .tag($0 as Int)
                    }
                }
                Picker("Make", selection: $vehicleMake) {
                    ForEach(VehicleMake.allCases, id: \.rawValue) {
                        Text($0.rawValue)
                            .tag($0 as VehicleMake)
                    }
                }
                if let vehicleMake, let vehicleYear {
                    Picker("Model", selection: $vehicleModel) {
                        ForEach(VehicleModel.allCases.filter(vehicleMake, vehicleYear), id: \.self) {
                            Text($0.rawValue)
                                .tag($0 as VehicleModel)
                        }
                    }
                }
            }
        }
    }
}

struct FeedVehicleFilterView_Previews: PreviewProvider {
    static var previews: some View {
        FeedVehicleFilterView(vehicleYear: .constant(2011), vehicleMake: .constant(.kia), vehicleModel: .constant(.elantra))
    }
}
