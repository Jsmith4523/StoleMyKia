//
//  ErrorView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 8/8/23.
//

import SwiftUI

struct ErrorView: View {
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 250)
            VStack(spacing: 10) {
                Image(systemName: "powercord")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                VStack(spacing: 3) {
                    Text("Whoops, an issue occurred")
                        .font(.system(size: 19).weight(.medium))
                    Text("Refresh to try again.")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
            }
            Spacer()
        }
        .multilineTextAlignment(.center)
        .padding()
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView()
    }
}
