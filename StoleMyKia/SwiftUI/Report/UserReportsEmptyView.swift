//
//  UserReportsEmptyView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/3/23.
//

import SwiftUI

struct UserReportsEmptyView: View {
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 200)
            VStack(spacing: 10) {
                Image(systemName: ApplicationTabViewSelection.feed.symbol)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                Text("We have nothing to report at the moment!")
                    .font(.system(size: 21))
            }
        }
        .foregroundColor(.gray)
        .padding()
        .multilineTextAlignment(.center)
    }
}

struct UserReportsEmptyView_Previews: PreviewProvider {
    static var previews: some View {
        UserReportsEmptyView()
    }
}
