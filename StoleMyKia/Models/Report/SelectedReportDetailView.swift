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
    
    @State private var testReport: Report? = .init(postDateTime: 1679504992, reportType: .stolen, vehicleYear: 2017, vehicleMake: .hyundai, vehicleColor: .red, vehicleModel: .accent, licensePlate: nil, vin: "", lat: 0, lon: 0)
    
    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(0...200, id: \.self) {
                    Text("\($0)")
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
