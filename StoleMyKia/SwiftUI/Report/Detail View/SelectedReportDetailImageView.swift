//
//  SelectedReportDetailImageView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 8/5/23.
//

import SwiftUI

struct SelectedReportDetailImageView: View {
    
    @Binding var vehicleImage: UIImage?
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
        }
        .statusBarHidden()
    }
}

struct SelectedReportDetailImageView_Previews: PreviewProvider {
    static var previews: some View {
        SelectedReportDetailImageView(vehicleImage: .constant(.vehiclePlaceholder))
    }
}
