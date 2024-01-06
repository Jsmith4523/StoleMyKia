//
//  SearchLicensePlateScannerView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 1/2/24.
//

import SwiftUI

struct CarLicenseScannerView: View {
    
    @StateObject private var cameraVM = CarLicenseScannerViewModel()
    
    @Environment (\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack(spacing: 20) {
                    cameraFeed
                    cameraControls
                }
            }
            .background {
                HostingView(statusBarStyle: .lightContent) {
                    EmptyView()
                        .disabled(true)
                }
            }
        }
    }
    
    private var cameraFeed: some View {
        ZStack(alignment: .bottom) {
            ZStack(alignment: .top) {
                CarLicenseScannerCameraFeedView(preview: cameraVM.preview)
            }
            if !(cameraVM.licensePlateDetected) {
                Text("Place License In View")
                    .font(.system(size: 18).bold())
                    .frame(height: 75)
                    .padding()
            }
        }
        .clipShape(CameraControlsShape())
        .ignoresSafeArea()
        .onAppear {
            cameraVM.checkAuthorization()
        }
    }
    
    private var cameraControls: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: cameraVM.flashMode == .on ? "flashlight.on.fill" : "flashlight.off.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .padding(15)
                    .foregroundColor(.black)
                    .background(.white.opacity(0.85))
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .padding()
                Spacer()
                Button {
                    
                } label: {
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(cameraVM.licensePlateDetected ? 0.5 : 0.15), lineWidth: 2)
                        ZStack {
                            Image(systemName: "squareshape.squareshape.dotted")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.black)
                            if !(cameraVM.licensePlateDetected) {
                                Image(systemName: "line.diagonal")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.black)
                            }
                        }
                        .frame(width: 32, height: 32)
                        .padding()
                        .frame(width: 68, height: 70)
                        .background(.white.opacity(cameraVM.licensePlateDetected ? 1 : 0.35))
                        .clipShape(Circle())
                    }
                    .frame(width: 75, height: 75)
                }
                .disabled(!cameraVM.licensePlateDetected)
                Spacer()
                Image(systemName: "xmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .padding(15)
                    .foregroundColor(.black)
                    .background(.white.opacity(0.75))
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .padding()
            }
            .padding()
        }
    }
}

fileprivate struct CameraControlsShape: Shape {
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: [.bottomLeft, .bottomRight],
                                cornerRadii: .init(width: 25, height: 35))
        return .init(path.cgPath)
    }
}

#Preview {
    CarLicenseScannerView()
}
