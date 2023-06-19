//
//  LicenseScannerPermissionDeniedView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/13/23.
//

import SwiftUI

struct LicenseScannerPermissionDeniedView: View {
    
    @EnvironmentObject var reportsModel: ReportsViewModel
    
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
                        Text("Permission Denied")
                            .font(.title.bold())
                        Text("Tap 'Open Settings' to change your camera permissions. Or, open 'Settings>StoleMyKia' to change your camera permissions.")
                    }
                    .foregroundColor(.white)
                    Button {
                        URL.openApplicationSettings()
                    } label: {
                        Text("System Settings")
                            .buttonStyle()
                    }
                }
                .multilineTextAlignment(.center)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        reportsModel.isShowingLicensePlateScannerView = false
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
}

private extension Text {
    
    func buttonStyle() -> some View {
        return self
            .foregroundColor(.brand)
            .padding()
            .background(.white)
            .clipShape(Capsule())
    }
}

struct LicenseScannerPermissionDeniedView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LicenseScannerPermissionDeniedView()
                .environmentObject(ReportsViewModel())
        }
    }
}
