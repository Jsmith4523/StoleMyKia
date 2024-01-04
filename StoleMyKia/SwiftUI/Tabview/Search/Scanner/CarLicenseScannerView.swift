//
//  SearchLicensePlateScannerView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 1/2/24.
//

import SwiftUI

struct CarLicenseScannerView: View {
    
    @StateObject private var cameraVM = CarLicenseScannerViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                cameraFeed
            }
        }
        .onAppear {
            cameraVM.setupCamera()
        }
        .background {
            HostingView(statusBarStyle: .lightContent) {
                EmptyView()
                    .disabled(true)
            }
        }
    }
    
    private var cameraFeed: some View {
        ZStack {
            
        }
    }
}

#Preview {
    CarLicenseScannerView()
}
