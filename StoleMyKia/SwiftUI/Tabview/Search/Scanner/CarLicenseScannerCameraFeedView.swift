//
//  CarLicenseScannerCameraFeedView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 1/3/24.
//

import Foundation
import UIKit
import SwiftUI

struct CarLicenseScannerCameraFeedView: UIViewRepresentable {
    
    @ObservedObject var cameraVM: CarLicenseScannerViewModel
    
    func makeUIView(context: Context) -> UIView {
        UIView()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    typealias UIViewType = UIView
}
