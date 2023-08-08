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
        ZStack {
            LicensePlateCameraView()
        }
        .environmentObject(scannerCoordinator)
        .environmentObject(reportsVM)
        .sheet(item: $scannerCoordinator.croppedLicensePlateImage) { image in
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        }
    }
}

extension UIImage: Identifiable {
    
    public var id: UUID {
        return UUID()
    }
}

struct LicenseScannerView_Previews: PreviewProvider {
    static var previews: some View {
        LicensePlateScannerView()
            .environmentObject(LicensePlateScannerCoordinator())
            .environmentObject(ReportsViewModel())
    }
}
