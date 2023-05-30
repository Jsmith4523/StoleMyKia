//
//  EditProfileVIew.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 5/30/23.
//

import SwiftUI

struct EditProfileView: View {
        
    @State private var vehicleYear: Int = 2011
    @State private var vehicleMake: VehicleMake = .hyundai
    @State private var vehicleModel: VehicleModel = .accent
    @State private var vehicleColor: VehicleColor = .black
    
    @ObservedObject var userModel: UserViewModel
    
    var body: some View {
        Form {
            Section {
                Picker("Vehicle Year", selection: $vehicleYear) {
                    ForEach(vehicleModel.year, id: \.self) {
                        Text(String($0))
                    }
                }
                Picker("Make", selection: $vehicleMake) {
                    ForEach(VehicleMake.allCases, id: \.self) {
                        Text($0.rawValue)
                            .tag($0)
                    }
                }
                Picker("Model", selection: $vehicleModel) {
                    ForEach(VehicleModel.allCases.filter(self.vehicleMake, self.vehicleYear), id: \.self) {
                        Text($0.rawValue)
                            .tag($0)
                    }
                }
                Picker("Color", selection: $vehicleColor) {
                    ForEach(VehicleColor.allCases, id: \.rawValue) {
                        Text($0.rawValue)
                            .tag($0)
                    }
                }
            } header: {
                Text("my vehicle")
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline  )
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    
                }
            }
        }
    }
}

struct EditProfileVIew_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EditProfileView(userModel: UserViewModel())
                .tint(.brand)
        }
    }
}
