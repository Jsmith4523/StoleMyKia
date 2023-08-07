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
    
    @Environment (\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            VStack {
                LicenseCameraViewRepresentable(scannerCoordinator: scannerCoordinator)
                    .frame(maxHeight: .infinity)
                VStack {
                    Divider()
                    Slider(value: $scannerCoordinator.zoomAmount, in: 0.0...2.0)
                        .padding([.horizontal, .top])
                    HStack {
                        Spacer()
                        Button {
                            prepareToDismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .padding()
                                .frame(width: 45, height: 45)
                                .padding()
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        Spacer()
                        Button {
                            scannerCoordinator.captureImage()
                        } label: {
                            Image(systemName: "camera.aperture")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .padding()
                                .frame(width: 65, height: 65)
                                .padding()
                                .foregroundColor(Color(uiColor: .systemBackground))
                                .background(Color(uiColor: .label))
                                .clipShape(Circle())
                        }
                        Spacer()
                        Button {
                            
                        } label: {
                            Image(systemName: "bolt.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .padding()
                                .frame(width: 45, height: 45)
                                .padding()
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    .padding()
                }
                .background(colorScheme == .dark ? .black : .white)
            }
            .tint(Color(uiColor: .label))
        }
        .onAppear {
            scannerCoordinator.setDelegate(reportsVM)
            scannerCoordinator.setupCamera()
        }
    }
    
    func prepareToDismiss() {
        scannerCoordinator.suspendCameraSession()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            reportsVM.isShowingLicensePlateScannerView = false
        }
    }
}

struct LicensePlateCameraView_Previews: PreviewProvider {
    static var previews: some View {
        LicensePlateCameraView()
            .environmentObject(LicensePlateScannerCoordinator())
            //.preferredColorScheme(.dark)
    }
}
