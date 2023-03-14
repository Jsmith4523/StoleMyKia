//
//  NewReportView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/13/23.
//

import SwiftUI

struct NewReportView: View {
    
    @State private var reportType: ReportType = .stolen
    
    @State private var vehicleMake: VehicleMake = .hyundai
    @State private var vehicleModel: String = ""
    @State private var vehicleYear: Int = 2011
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker("Report type", selection: $reportType) {
                        ForEach(ReportType.allCases, id: \.rawValue) {
                            Text($0.rawValue)
                                .tag($0)
                        }
                    }
                } header: {
                    Text("Report Information")
                }
                Section {
                    Picker("Year", selection: $vehicleYear) {
                        ForEach(Report.affectedVehicleYears, id: \.self) {
                            Text(String($0))
                                .tag($0)
                        }
                    }
                    Picker("Make", selection: $vehicleMake) {
                        ForEach(VehicleMake.allCases, id: \.rawValue) {
                            Text($0.rawValue)
                                .tag($0)
                        }
                    }
                    TextField("Model", text: $vehicleModel)
                } header: {
                    Text("Vehicle Information")
                }
            }
            .navigationTitle("New Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button {
                    
                } label: {
                    Image(systemName: "xmark")
                }
            }
        }
    }
}

struct NewReportView_Previews: PreviewProvider {
    static var previews: some View {
        NewReportView()
            .accentColor(.red)
    }
}
