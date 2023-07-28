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
                .frame(height: 150)
            Image(systemName: ApplicationTabViewSelection.feed.symbol)
                .resizable()
                .scaledToFit()
                .frame(width: 65, height: 65)
            VStack(spacing: 8) {
                Text("Nothing to report at the moment..")
                    .font(.system(size: 22).bold())
                Text("Some would say that's a good thing.")
                    .font(.body)
                    .foregroundColor(.gray)
            }
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
