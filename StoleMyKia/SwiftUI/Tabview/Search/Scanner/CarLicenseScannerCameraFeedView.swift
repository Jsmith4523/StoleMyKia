//
//  CarLicenseScannerCameraFeedView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 1/3/24.
//

import Foundation
import UIKit
import SwiftUI
import AVFoundation

struct CarLicenseScannerCameraFeedView: UIViewRepresentable {
    
    let preview: AVCaptureVideoPreviewLayer
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.frame.size = UIScreen.main.bounds.size
        preview.frame = view.frame
        preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(preview)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
}
