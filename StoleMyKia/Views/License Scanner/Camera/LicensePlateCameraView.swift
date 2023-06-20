//
//  LicensePlateCameraView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/13/23.
//

import SwiftUI

struct LicensePlateCameraView: View {
    
    @EnvironmentObject var reportsVM: ReportsViewModel
    @EnvironmentObject var scannerCoordinator: LicensePlateScannerCoordinator
    
    var body: some View {
        VStack {
            LicenseCameraViewRepresentable(scannerCoordinator: scannerCoordinator)
        }
        .onAppear {
            scannerCoordinator.setDelegate(reportsVM)
        }
        .toolbar {
            
        }
    }
}

struct LicensePlateCameraView_Previews: PreviewProvider {
    static var previews: some View {
        LicensePlateCameraView()
            .environmentObject(LicensePlateScannerCoordinator())
            .environmentObject(ReportsViewModel())
    }
}
