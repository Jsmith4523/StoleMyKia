//
//  LicensePlateScannerView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 5/1/23.
//

import SwiftUI

struct LicensePlateScannerView: View {
    
    @StateObject private var licenseModel = LicenseScannerCoordinator()
    @EnvironmentObject var reportsModel: ReportsViewModel
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        CustomNavView(title: "Plate Scanner", statusBarColor: .darkContent, backgroundColor: .brand) {
            ZStack {
                Color.black.ignoresSafeArea()
                LicenseCameraSession(coordinator: licenseModel)
                    .ignoresSafeArea()
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
                    Button {
                        licenseModel.toggleTorch()
                    } label: {
                        Image(systemName: licenseModel.torchIsOn ? "sun.max.fill" : "sun.min.fill")
                    }
                }
            }
            .accentColor(.white)
        }
        .ignoresSafeArea()
        .onAppear {
            licenseModel.checkPermissions()
            licenseModel.setLicensePlateDelegate(reportsModel)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                licenseModel.fetchReports()
            }
        }
    }
}

struct LicensePlateScannerView_Previews: PreviewProvider {
    static var previews: some View {
        LicensePlateScannerView()
            .environmentObject(ReportsViewModel())
    }
}
