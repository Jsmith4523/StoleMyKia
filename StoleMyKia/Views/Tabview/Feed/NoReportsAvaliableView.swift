//
//  NoReportsAvaliableView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/10/23.
//

import SwiftUI

struct NoReportsAvaliableView: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
                .frame(height: 175)
            Image(systemName: "square.stack.3d.down.right")
                .resizable()
                .scaledToFit()
                .frame(width: 75, height: 75)
                .foregroundColor(.brand)
            Text("Nothing to report at the moment")
                .font(.title.weight(.bold))
            Text("That's a good thing!")
                .font(.title2)
            Spacer()
        }
        .multilineTextAlignment(.center)
        .padding()
    }
}

struct NoReportsAvaliableView_Previews: PreviewProvider {
    static var previews: some View {
        NoReportsAvaliableView()
    }
}
