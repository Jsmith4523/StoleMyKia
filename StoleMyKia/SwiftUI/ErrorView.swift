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
            VStack(spacing: 9) {
                Image(systemName: "exclamationmark.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
                    .foregroundColor(.red)
                Text("Sorry, we ran into an error. Refresh this screen to try again")
                    .font(.system(size: 18))
                    .foregroundColor(.gray)
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
