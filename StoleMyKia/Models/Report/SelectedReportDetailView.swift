//
//  SelectedReportDetailView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/14/23.
//

import SwiftUI

struct SelectedReportDetailView: View {
    
    @State private var report: Report? = Report(dt: 1679994594.5491061, reportType: .stolen, vehicleYear: 2017, vehicleMake: .hyundai, vehicleColor: .silver, vehicleModel: .elantra, licensePlate: nil, vin: nil, imageURL: "https://firebasestorage.googleapis.com:443/v0/b/stolemykia.appspot.com/o/CCE42EFF-0911-4DE4-95F7-7D5B544E87A3?alt=media&token=b2c42be7-88c4-4f16-9798-804429c455e6", lat: 0, lon: 0)
    
    @EnvironmentObject var reportsModel: ReportsViewModel
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                if let report = reportsModel.selectedReport {
                    VStack {
                        Image(uiImage: report.vehicleImage())
                            .resizable()
                            .scaledToFit()
                        VStack {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(report.type)
                                        .font(.system(size: 30).weight(.heavy))
                                    Text(report.vehicleDetails)
                                        .font(.system(size: 17))
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                        }
                        .padding()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            
                        } label: {
                            Label("Directions", systemImage: "map")
                        }
                        Button {
                            
                        } label: {
                            Label("Bookmark", systemImage: "bookmark")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
            }
            .accentColor(Color(uiColor: .label))
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
