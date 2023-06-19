//
//  LicenseScannerView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/13/23.
//

import SwiftUI

struct LicensePlateScannerView: View {
    
    @EnvironmentObject var reportsVM: ReportsViewModel
    @StateObject private var scannerCoordinator = LicensePlateScannerCoordinator()
    
    var body: some View {
        NavigationView {
            ZStack {
                switch scannerCoordinator.permissionAccess {
                case .authorized:
                    LicensePlateCameraView()
                case .denied:
                    LicenseScannerPermissionDeniedView()
                case .pending:
                    LicenseScannerRequestPermissionView()
                }
            }
        }
        .environmentObject(scannerCoordinator)
        .environmentObject(reportsVM)
    }
}

struct LicenseScannerView_Previews: PreviewProvider {
    static var previews: some View {
        LicensePlateScannerView()
            .environmentObject(LicensePlateScannerCoordinator())
            .environmentObject(ReportsViewModel())
    }
}
