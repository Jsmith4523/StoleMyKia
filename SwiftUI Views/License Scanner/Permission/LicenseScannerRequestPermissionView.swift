//
//  LicenseScannerRequestPermissionView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/13/23.
//

import SwiftUI

struct LicenseScannerRequestPermissionView: View {
    
    @EnvironmentObject var reportsVM: ReportsViewModel
    @EnvironmentObject var scannerCoordinator: LicensePlateScannerCoordinator
    
    var body: some View {
        HostingView(statusBarStyle: .lightContent) {
            ZStack {
                Color.brand.ignoresSafeArea()
                VStack(spacing: 50) {
                    VStack(spacing: 20) {
                        Image(systemName: "camera")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                        Text("Allow access to camera?")
                            .font(.title.bold())
                        Text("The license plate scanner requires full access to your device's camera in order to accurately scan license plates.")
                    }
                    .foregroundColor(.white)
                    VStack(spacing: 10) {
                        Button {
                            scannerCoordinator.askForPermission()
                        } label: {
                            Text("Continue")
                                .buttonStyle()
                        }
                        Button {
                            reportsVM.isShowingLicensePlateScannerView = false
                        } label: {
                            Text("Close")
                                .buttonStyle()
                        }
                    }
                }
                .multilineTextAlignment(.center)
                .padding()
            }
        }
        .ignoresSafeArea()
    }
}

struct LicenseScannerRequestPermissionView_Previews: PreviewProvider {
    static var previews: some View {
        LicenseScannerRequestPermissionView()
            .environmentObject(ReportsViewModel())
            .environmentObject(LicensePlateScannerCoordinator())
    }
}
