//
//  LicensePlateScannerView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 5/1/23.
//

import SwiftUI

struct LicensePlateScannerView: View {
    var body: some View {
        CustomNavView(statusBarColor: .darkContent, backgroundColor: .black.opacity(0.5)) {
            Color.red
                .ignoresSafeArea()
        }
        .ignoresSafeArea()
    }
}

struct LicensePlateScannerView_Previews: PreviewProvider {
    static var previews: some View {
        LicensePlateScannerView()
    }
}
