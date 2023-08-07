//
//  SkeletonLoadingCellView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 8/5/23.
//

import SwiftUI

struct SkeletonLoadingCellView: View {
    var body: some View {
        VStack {
            Image(uiImage: .vehiclePlaceholder)
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width, height: 250)
                .clipped()
            VStack(alignment: .leading) {
                HStack {
                    Text("Lorem Ipsum")
                        .font(.system(size: 17))
                    Spacer()
                    Text("Lorem Ipsum")
                        .font(.system(size: 17))
                }
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("2017 Hyundai Elantra (Gray)")
                            .font(.system(size: 24))
                        Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")
                    }
                }
            }
            .padding()
        }
        .accessibilityValue(Text("Placeholder"))
        .redacted(reason: .placeholder)
    }
}

struct SkeletonLoadingCellView_Previews: PreviewProvider {
    static var previews: some View {
        SkeletonLoadingCellView()
    }
}
