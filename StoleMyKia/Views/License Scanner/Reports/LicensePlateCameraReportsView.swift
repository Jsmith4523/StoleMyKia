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
                
            }
            .navigationTitle(scannerCoordinator.licensePlateString)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct LicensePlateCameraReportsView_Previews: PreviewProvider {
    static var previews: some View {
        LicensePlateCameraReportsView()
            .environmentObject(ReportsViewModel())
            .environmentObject(LicensePlateScannerCoordinator())
    }
}
