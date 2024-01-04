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
                Text("Whoops, an issue occurred. Refresh to try again")
                    .font(.system(size: 19).bold())
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
