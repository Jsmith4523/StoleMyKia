//
//  ApplicationProgressView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 7/17/23.
//

import SwiftUI

struct ApplicationProgressView: View {
    var body: some View {
        ZStack {
            Color.brand.ignoresSafeArea()
            VStack(spacing: 20 ) {
                Image(systemName: "car.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
                ProgressView()
                    .tint(.white)
            }
        }
    }
}

struct MyPreviewProvider69Nice_Previews: PreviewProvider {
    static var previews: some View {
        ApplicationProgressView()
    }
}
