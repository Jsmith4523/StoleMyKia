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
        HostingView(statusBarStyle: .lightContent) {
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
                            
                        } label: {
                            Image(systemName: "circle.slash")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                        }
                    }
                    .foregroundColor(.white)
                    .bold()
                    .padding()
                    LicenseCameraViewRepresentable(scannerCoordinator: scannerCoordinator)
                        .frame(height: UIScreen.main.bounds.height/1.5)
                        .cornerRadius(30)
                    VStack {
                        Slider(value: $value)
                            .tint(.white)
                        Spacer()
                    }
                    .padding()
                    Spacer()
                }
                .padding(.horizontal, 5)
            }
        }
        .ignoresSafeArea()
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
