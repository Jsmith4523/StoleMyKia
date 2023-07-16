//
//  LicensePlateCameraView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/13/23.
//

import SwiftUI

struct LicensePlateCameraView: View {
    
    @State private var value = 0.0
    
    @EnvironmentObject var reportsVM: ReportsViewModel
    @EnvironmentObject var scannerCoordinator: LicensePlateScannerCoordinator
    
    var body: some View {
        //HostingView(statusBarStyle: .lightContent) {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack {
                    HStack {
                        Button {
                            reportsVM.isShowingLicensePlateScannerView = false
                        } label: {
                            Image(systemName: "xmark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                        }
                        Spacer()
                        Button {
                            
                        } label: {
                            Image(systemName: "questionmark.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                        }
                        Spacer()
                        Button {
                            scannerCoordinator.captureImage()
                        } label: {
                            Image(systemName: "circle.slash")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                        }
                    }
                    .foregroundColor(.white)
                    .padding()
                    LicenseCameraViewRepresentable(scannerCoordinator: scannerCoordinator)
                        .frame(height: UIScreen.main.bounds.height/1.5)
                        .cornerRadius(30)
                    VStack {
                        HStack {
                            Image(systemName: "minus")
                            Slider(value: $value)
                                .padding(.horizontal, 7)
                                .tint(.white)
                            Image(systemName: "plus")
                        }
                        .foregroundColor(.white)
                        .font(.system(size: 22).bold())
                        Spacer()
                    }
                    .padding()
                    Spacer()
                    if let licenseImage = scannerCoordinator.croppedLicensePlateImage {
                        Image(uiImage: licenseImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    }
                }
                .padding(.horizontal, 5)
            }
        }
        // }
        .ignoresSafeArea()
        .onAppear {
            scannerCoordinator.setDelegate(reportsVM)
            scannerCoordinator.setupCamera()
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
