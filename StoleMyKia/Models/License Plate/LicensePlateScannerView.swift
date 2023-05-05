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
                ZStack(alignment: .bottomTrailing) {
                    LicenseCameraSession(coordinator: licenseModel)
                        .ignoresSafeArea()
                    ScannerControls
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
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        
                    } label: {
                        Image(systemName: "waveform.and.mic")
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
        .alert("Warning, your are activating your flash!", isPresented: $licenseModel.alertTorchUsage, actions: {
            Button("Activate", role: .destructive) {
                licenseModel.toggleTorch()
            }
            Button("Always activate", role: .destructive) {
                licenseModel.toggleTorchWithLearning()
            }
        }, message: {
            Text("We want to ensure the safety of everyone. For your safety, please do not direct your flash that would be in view for the thief. If the camera is unable to detect the license plate, please search it manually.")
        })
//        .customSheetView(isPresented: $licenseModel.presentLicenseResultsView, detents: [.medium(), .large()], showsIndicator: true, cornerRadius: 30) {
//            LicensePlateResultsView(licenseModel: licenseModel)
//                .onAppear {
//                    licenseModel.startSession()
//                }
//                .onDisappear {
//                    licenseModel.startSession()
//                }
//        }
    }
    
    var ScannerControls: some View {
        HStack {
            Button {
                licenseModel.warnOfTorchUse()
            } label: {
                Image(systemName: "flashlight.on.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
                    .padding()
                    .foregroundColor(.black)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 2)
                    .rotationEffect(.degrees(-30))
            }
        }
        .padding()
    }
}

struct LicensePlateScannerView_Previews: PreviewProvider {
    static var previews: some View {
        LicensePlateScannerView()
            .environmentObject(ReportsViewModel())
    }
}
