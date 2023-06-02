//
//  UpdateReportView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/1/23.
//

import SwiftUI

struct UpdateReportView: View {
    
    let report: Report
    
    @State private var isShowingLocationSearchView = false
    
    @State private var vehicleImage: UIImage?
    @State private var updateReportType: ReportType = .found
    
    @State private var location: Location?
    
    @Environment (\.dismiss) var dismiss
        
    var body: some View {
        NavigationView {
            List {
                Section {
                    Picker("Update Type", selection: $updateReportType) {
                        ForEach(ReportType.update) { type in
                            Text(type.rawValue)
                                .tag(type)
                        }
                    }
                    HStack {
                        Text("Vehicle")
                        Spacer()
                        Text(report.vehicleDetails)
                            .font(.system(size: 17))
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("License")
                        Spacer()
                        Text(report.licensePlateString ?? "Not Avaliable")
                            .font(.system(size: 17))
                            .foregroundColor(.gray)
                    }
                } header: {
                    Text("Update Details")
                } footer: {
                    Text("Most details have already been applied to this update.")
                }
                
                Section {
                    
                } header: {
                    Text("Location")
                } footer: {
                    Text("Depending on your location services settings, your current location has been applied to this report.")
                }
            }
            .navigationTitle("Update Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .bold()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Update") {
                        
                    }
                    .bold()
                    .disabled(true)
                }
            }
            .sheet(isPresented: $isShowingLocationSearchView) {
                LocationSearchView(location: $location)
            }
        }
    }
}

struct UpdateReportView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateReportView(report: .init(dt: Date.now.epoch, reportType: .spotted, vehicle: .init(vehicleYear: 2017, vehicleMake: .hyundai, vehicleColor: .black, vehicleModel: .elantra), distinguishable: "", location: nil))
    }
}
