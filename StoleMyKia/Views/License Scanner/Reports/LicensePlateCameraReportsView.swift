//
//  LicensePlateCameraReportsView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/13/23.
//

import SwiftUI

struct LicensePlateCameraReportsView: View {
        
    @EnvironmentObject var reportsVM: ReportsViewModel
    @EnvironmentObject var scannerCoordinator: LicensePlateScannerCoordinator
    
    var body: some View {
        NavigationView {
            VStack {
                switch scannerCoordinator.reports.isEmpty {
                case true:
                    noResultsFound
                case false:
                    LicensePlateReportsListView()
                }
            }
            .navigationTitle(scannerCoordinator.licensePlateString)
            .navigationBarTitleDisplayMode(.inline)
            .presentationDetents([.height(600)])
        }
        .environmentObject(reportsVM)
        .environmentObject(scannerCoordinator)
    }
    
    var noResultsFound: some View {
        VStack {
            Text("Nothing was found for license no. \(scannerCoordinator.licensePlateString)")
                .font(.system(size: 17))
                .foregroundColor(.gray)
        }
    }
}

fileprivate struct LicensePlateReportsListView: View {
    
    @EnvironmentObject var reportsVM: ReportsViewModel
    @EnvironmentObject var scannerCoordinator: LicensePlateScannerCoordinator
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(reportsVM.reports) { report in
                    LicensePlateReportsCellView(report: report)
                    Divider()
                        .padding(.horizontal)
                }
            }
            .refreshable {
                
            }
        }
    }
}

struct LicensePlateReportsCellView: View {
    
    @State private var vehicleImage: UIImage?
    
    let report: Report
    
    @EnvironmentObject var reportsVM: ReportsViewModel
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text(report.reportType.rawValue)
                    .font(.system(size: 23).weight(.heavy))
                Text(report.vehicleDetails)
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                Text(report.vehicle.licensePlateString)
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
            }
            Spacer()
            if report.hasVehicleImage {
                Image(uiImage: vehicleImage ?? .vehiclePlaceholder)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 85, height: 85)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            }
        }
        .padding()
        .onAppear {
            report.vehicleImage { image in
                self.vehicleImage = image
            }
        }
    }
}

struct LicensePlateCameraReportsView_Previews: PreviewProvider {
    static var previews: some View {
        LicensePlateReportsCellView(report: [Report].testReports().filter({$0.hasVehicleImage}).first!)
            .environmentObject(ReportsViewModel())
            .environmentObject(LicensePlateScannerCoordinator())
    }
}
